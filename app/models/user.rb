require 'digest/sha1'

class User < NattoBase
  #################
  # CONSTANTS
  
  # RE_LOGIN_OK   = /\A\w[\w\.\-_@]+\z/                   # ASCII, strict
  RE_LOGIN_OK     = /\A[[:alnum:]][[:alnum:]\.\-_@]+\z/       # Unicode, strict
  # RE_LOGIN_OK   = /\A[^[:cntrl:]\\<>\/&]*\z/              # Unicode, permissive
  MSG_LOGIN_BAD   = "must contain only letters, numbers, and .-_@ please."
  MSG_BLANK_LOGIN = "can't be blank, unless OpenID is specified."

  RE_NAME_OK      = /\A[^[:cntrl:]\\<>\/&]*\z/              # Unicode, permissive
  MSG_NAME_BAD    = "must not contain non-printing characters or \\&gt;&lt;&amp;/ please."

  # This is purposefully imperfect -- it's just a check for bogus input. See
  # http://www.regular-expressions.info/email.html
  RE_EMAIL_NAME   = '[\w\.%\+\-]+'                          # what you actually see in practice
  #RE_EMAIL_NAME   = '0-9A-Z!#\$%\&\'\*\+_/=\?^\-`\{|\}~\.' # technically allowed by RFC-2822
  RE_DOMAIN_HEAD  = '(?:[a-zA-Z0-9\-]+\.)+'
  RE_DOMAIN_TLD   = '(?:[A-Z]{2}|com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|museum)'
  RE_EMAIL_OK     = /\A#{RE_EMAIL_NAME}@#{RE_DOMAIN_HEAD}#{RE_DOMAIN_TLD}\z/i
  MSG_EMAIL_BAD   = "should look like an email address."
  
  IDENTITY_URL_OK       = /\Ahttp:\/\/#{RE_DOMAIN_HEAD}#{RE_DOMAIN_TLD}[\/]?\z/i
  MSG_IDENTITY_URL_BAD  = "should look like a valid URL."
  MSG_BLANK_OPENID      = "can't be blank unless login is specified."
  
  #################
  # VALIDATIONS
  
  validates_uniqueness_of   :email, :case_sensitive => false
  validates_presence_of     :email
  validates_length_of       :email, :within => 6..100,                                :if => :not_email_blank?
  validates_format_of       :email, :with => RE_EMAIL_OK, :message => MSG_EMAIL_BAD,  :if => :not_email_blank?
  
  validates_uniqueness_of   :identity_url, :on => :create, :case_sensitive => false, :allow_nil => true
  validates_presence_of     :identity_url, :message => MSG_BLANK_OPENID,                               :if => :login_blank?
  validates_length_of       :identity_url, :within => 10..100,                                         :if => :not_openid_blank?
  validates_format_of       :identity_url, :with => IDENTITY_URL_OK, :message => MSG_IDENTITY_URL_BAD, :if => :not_openid_blank?
  
  validates_uniqueness_of   :login, :on => :create, :case_sensitive => false, :allow_nil => true
  validates_presence_of     :login, :if => :identity_url.blank?,                      :if => :openid_blank?
  validates_length_of       :login, :within => 3..40,                                 :if => :not_login_blank?
  validates_format_of       :login, :with => RE_LOGIN_OK, :message => MSG_LOGIN_BAD,  :if => :not_login_blank?
  
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :password, :within => 6..40, :if => :not_password_blank?
  
  validates_format_of       :first_name,  :with => RE_NAME_OK,  :message => MSG_NAME_BAD, :allow_nil => true
  validates_length_of       :first_name,  :maximum => 40
  
  validates_format_of       :last_name,   :with => RE_NAME_OK,  :message => MSG_NAME_BAD, :allow_nil => true
  validates_length_of       :last_name,   :maximum => 40
  
  #################
  # ASSOCIATIONS
  has_and_belongs_to_many :roles
  has_many :change_logs
  
  #################
  # Let's set the password before we save the record
  before_save :encrypt_password
  
  # some fake columns
  attr_accessor :password, :password_confirmation, :new_email
    
  #################
  # Prevent the user from skipping the activation process via a custom form
  # Also allows modification via bulk-setters
  
  # login and openid should stay off of this list
  attr_accessible :email, :first_name, :last_name, :password, :password_confirmation, :role_ids
  
  #################
  # User states
  
  acts_as_state_machine :initial => :passive, :column => "aasm_state"
  
  state :passive
  state :pending,   :enter => :do_pending
  state :active,    :enter => :do_activate
  state :forgetful, :enter => :do_forget
  state :suspended
  state :deleted,   :enter => :do_delete
  
  event :pacify do
    transitions :from => [:pending, :active, :suspended, :deleted], :to => :passive
  end
  
  event :register do
    transitions :from => :passive, :to => :pending, :guard => Proc.new {|u| !(u.crypted_password.blank? && u.password.blank?) }
  end
  
  event :activate do
    transitions :from => [:passive, :pending, :forgetful], :to => :active
  end
  
  event :suspend do
    transitions :from => [:passive, :pending, :active, :forgetful], :to => :suspended
  end
  
  event :forget do
    transitions :from => [:passive, :active], :to => :forgetful
  end
  
  event :remember do
    transitions :from => :forgetful, :to => :active 
  end
  
  event :delete do
    transitions :from => [:passive, :pending, :active, :forgetful, :suspended], :to => :deleted
  end
  
  event :undelete do
    transitions :from => :deleted, :to => :active
  end
  
  event :unsuspend do
    transitions :from => :suspended, :to => :active,  :guard => Proc.new {|u| !u.activated_at.blank? } # dangerous check... email_confirmed?
    transitions :from => :suspended, :to => :pending, :guard => Proc.new {|u| !u.activation_code.blank? }
    transitions :from => :suspended, :to => :passive
  end

  ###################################
  # Handle state transition events
  
  def do_pending
    make_activation_code
    # send the user an email with an activation code
    UserMailer.deliver_signup_notification(self)
  end
  protected :do_pending
  
  def do_activate
    self.activation_code = self.password_reset_code = nil
  end
  protected :do_activate
  
  def do_delete
    self.password_reset_code = nil
  end
  protected :do_delete
  
  def do_forget
    make_password_reset_code
    UserMailer.deliver_forgetful_notification(self)
  end
  ###################################
  
  # generate our activation code
  def make_activation_code
    self.activation_code = self.class.make_token
  end
  private :make_activation_code
  
  def make_password_reset_code
    self.password_reset_code = self.class.make_token
  end
  private :make_password_reset_code
  
  # Encrypts our password for us, before a save
  def encrypt_password
    return if password.blank?
    self.salt = User.make_token if new_record?
    self.crypted_password = encrypt(password)
  end
  
  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  def self.authenticate(login, password)
    user = find_in_state :first, :active, :conditions => {:login => login} # need to get the salt
    user && user.authenticated?(password) ? user : nil
  end
  
  # convenience, so we don't have to keep passing the salt
  def encrypt(password)
    User.password_digest(password, salt)
  end
  
  # This provides a modest defense against a dictionary attack.
  # Must pass both parameters, since it's a class method, and not
  # an instance method.
  #
  # See the file config/initializers/site_keys.rb
  def self.password_digest(password, salt)
    digest = REST_AUTH_SITE_KEY
    REST_AUTH_DIGEST_STRETCHES.times do
      digest = secure_digest(digest, salt, password, REST_AUTH_SITE_KEY)
    end
    digest
  end
  
  def self.secure_digest(*args)
    Digest::SHA1.hexdigest(args.flatten.join('--'))
  end
  
  # This generates items such as our activation_code and password_reset_code
  def self.make_token
    secure_digest(Time.now, (1..10).map{ rand.to_s })
  end
  
  # convenience method to concatenate first and last name
  def name
    output  = ""
    output += first_name + ' '  unless first_name.blank?
    output += last_name         unless last_name.blank?
    output.strip
  end
  
  ##########################
  # COOKIE FUNCTIONS
  
  def remember_token?
    (!remember_token.blank?) && remember_token_expires_at && (Time.now.utc < remember_token_expires_at.utc)
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = self.class.make_token
    save(false)
  end

  # refresh token (keeping same expires_at) if it exists
  def refresh_token
    if remember_token?
      self.remember_token = self.class.make_token 
      save(false)      
    end
  end

  # 
  # Deletes the server-side record of the authentication token.  The
  # client-side (browser cookie) and server-side (this remember_token) must
  # always be deleted together.
  #
  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
  
  def self.authorized_for_page?(user, page)
    if user.nil?
      page.roles.empty?
    elsif page.roles.empty?
      return true
    else
      return true if user.is_administrator?
      page.roles.each do |role|
        return true if user.has_role?(role.title)
      end
      return false
    end
  end
  
  #############################
  # ROLE FUNCTIONS
  
  def is_administrator?
    self.has_role?('administrator')
  end
  
  def has_role?(role)
    case role.class.name
      when "String"
        self.roles.find_by_title(role) ? true : false
      when "Role"
        self.roles.include?(role)
      else
        logger.debug(role.class.name)
        false
    end
  end
  
  def self.exists?(user = nil)
    return false if user.nil?
    if user.is_a?(User) 
      user_id = user.id
    elsif user.is_a?(Integer)
      user_id = user
    else
      return false
    end
    User.find_by_id(user_id) ? true : false
  end
  
  def authentication_id
    login.blank? ? identity_url : login
  end
  
  private
  # Validation aid.
  def login_required?
    self.identity_url.blank? || self.identity_url.nil?
  end
  # Validation aid.
  def login_blank?
    self.login.blank?
  end
  # Validation aid.
  def not_login_blank?
    !login_blank?
  end
  # Validation aid.
  def openid_blank?
    self.identity_url.blank?
  end
  # Validation aid.
  def not_openid_blank?
    !openid_blank?
  end
  # Validation aid.
  def password_blank?
    self.password.blank?
  end
  # Validation aid.
  def not_password_blank?
    !password_blank?
  end
  # Validation aid.
  def email_blank?
    self.email.blank?
  end
  # Validation aid.
  def not_email_blank?
    !email_blank?
  end
  def password_required?
    (not_login_blank? || openid_blank?) && (crypted_password.blank? || !password.blank?)
  end
end
