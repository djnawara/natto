require 'openid'
require 'openid/store/filesystem'
require 'openid/extensions/sreg'

class UsersController < CrudController
  before_filter :find_object, :only => [:suspend, :unsuspend, :destroy, :undelete, :purge, :edit, :update, :show, :roles, :process_role]
  before_filter :logged_in_as_admin_or_not_logged_in_required, :only => [:new, :create] # only administrators can make user accounts
  skip_before_filter :login_required, :only => [:new, :create, :activate, :forgot_password, :prepare_password_reset, :reset_password, :do_reset]
  skip_before_filter :admin_required, :only => [:new, :create, :activate, :forgot_password, :prepare_password_reset, :reset_password, :do_reset, :show, :account, :edit, :update, :destroy]
  
  IMMEDIATE_MODE = false
  
  # These aren't stricly necessary, but do give the user some feedback
  # as to why an action isn't working.  State events fail silently
  # if the object isn't in the correct state for the transition.
  before_filter :only => :suspend do |controller|
    controller.send(:state_check, [:passive, :pending, :active, :forgetful])
  end
  
  before_filter :only => :unsuspend do |controller|
    controller.send(:state_check, :suspended)
  end
  
  before_filter :only => :destroy do |controller|
    controller.send(:state_check, [:passive, :pending, :active, :forgetful, :suspended])
  end
  
  before_filter :only => :undelete do |controller|
    controller.send(:state_check, :deleted)
  end
  
  # This check is necessary to make sure only :deleted items are destroyed.
  before_filter :only => :purge do |controller|
    controller.send(:state_check, :deleted)
  end
  
  def build_registration_data_request
    # let's collect registration data
    registration_data_request = OpenID::SReg::Request.new
    # collect this
    registration_data_request.request_fields(['email','nickname'], true)
    # do not collect these fields
    registration_data_request.request_fields(['dob', 'fullname'], false)
    # return the registration data request
    registration_data_request
  end
  protected :build_registration_data_request
  
  def request_sreg
    openid_url = params[:user][:identity_url] || params[:identity_url]
    begin
      request = openid_consumer.begin(openid_url)
    rescue OpenID::OpenIDError => e
      flash[:error] = "Discovery failed for '#{openid_url}': #{e}"
      redirect_to :controller => 'users', :action => 'new'
      return false
    end
    # add the registration data request to our OID request object
    request.add_extension(build_registration_data_request)
    params[:user].each do |key, value|
      request.return_to_args[key] = value unless value.blank?
    end
    # setup up the return URL
    return_to = signup_url
    realm = root_url
    # this sends our OID request off to the OID server
    if request.send_redirect?(realm, return_to, IMMEDIATE_MODE)
      redirect_to request.redirect_url(realm, return_to, IMMEDIATE_MODE)
      flash[:notice] = "User registration information was loaded from your OpenID URL."
      return true
    else
      render :text => request.html_markup(realm, return_to, IMMEDIATE_MODE, {'id' => 'openid_form'})
      return true
    end
  end
  
  def new
    # Parse the name out of the registration data
    if params['openid.sreg.fullname']
      name        = params['openid.sreg.fullname'].split(' ')
      last_name   = name.pop
      first_name  = name.collect {|segment| segment.chars.capitalize}.join(' ')
    end
    # build a new user object with the collected information
    @object = User.new({
      :last_name    => params[:last_name] || last_name || '',
      :first_name   => params[:first_name] || first_name || '',
      :email        => params[:email] || params['openid.sreg.email'] || '' })
    # grab the identity url as returned
    identity_url = params['openid.identity'] || params[:identity_url] || ''
    # grab login
    login = params[:login] || params['openid.sreg.nickname'] || ''
    login = login.chars.downcase unless login.blank?
    # these must be manually set
    @object.identity_url = identity_url
    @object.login = login
    # render the form
    respond_to do |format|
      format.html { render :template => 'users/form' }
      format.xml  { render :xml => @object }
    end
  end
  
  # POST /users
  # POST /users.xml
  def create
    return request_sreg unless params[:user][:identity_url].blank? || !params[:commit].eql?('Load from OpenID')
    logout_keeping_session! unless logged_in? && current_user.is_administrator?
    @object = User.new(params[:user])
    # Add attributes not available to mass-assign
    login         = params[:user][:login]
    identity_url  = params[:user][:identity_url]
    @object.login         = (login.blank? ? nil : login)
    @object.identity_url  = (identity_url.blank? ? nil : identity_url)
    success = @object && @object.valid?
    @object.save! if success
    # the normal case of user signup
    @object.register! if success && params[:activate].to_i != 1
    # special case for administrators creating accounts
    if success && params[:activate].to_i == 1 && (logged_in? && current_user.is_administrator?)
      @object.activate!
      create_change_log_entry(@object.id, nil, 'activate', 'Automatic user activation on create.')
    end
    respond_to do |format|
      if success && @object.errors.empty?
        if logged_in? && current_user.is_administrator?
          flash[:notice] = 'The account has been created!'
          create_change_log_entry
          format.html { redirect_to(users_path) }
          format.xml  { render :xml => @object, :status => :created, :location => @object }
        else
          flash[:notice] = 'Your account has been created!  Please check your email, to complete the activation process.'
          create_change_log_entry(@object.id, @object.id)
          format.html { redirect_to(login_path) }
          format.xml  { render :xml => @object, :status => :created, :location => @object }
        end
      else
        flash.now[:error] = "We couldn't set up your account, sorry.  Please try again, or contact the site administrator."
        format.html { render :action => 'new', :template => 'users/form' }
        format.xml  { render :xml => @object.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /users/1
  # PUT /users/1.xml
  def update
    # add a blank set of ids, so that we can actually remove roles
    user_hash = {:role_ids => []}
    # merge in what the user has selected
    user_hash = (params[:user].has_key?(:role_ids) ? params[:user] : params[:user].merge({:role_ids => []})) if params[:user]
    # locate the admin role id
    admin_role_id = Role.find_by_title('administrator').id
    # don't let the current user remove their administrative role
    if @object == current_user && @object.is_administrator? && !user_hash[:role_ids].include?(admin_role_id.to_s)
      user_hash[:role_ids] = user_hash[:role_ids] << admin_role_id
      flash[:warning] = 'You cannot remove the administrator role from yourself.'
    end
    # check for new email
    if !params[:user][:new_email].blank? && !params[:user][:email].eql?(params[:user][:new_email])
      params[:user][:email] = params[:user][:new_email]
      params[:user][:new_email] = nil
    end
    # execute the standard CrudController update
    super
  end
  
  # We don't actually remove the user record
  def destroy
    logout_killing_session! if @object == current_user
    User.transaction do
      @object.delete!
      create_change_log_entry
    end
    respond_to do |format|
      format.html { redirect_to(users_path) }
      format.xml  { head :ok }
    end
  end
  
  # DELETE /users/:id/purge
  # DELETE /users/:id/purge.xml
  def purge
    respond_to do |format|
      if @object.current_state == :deleted
        if @object.is_administrator?
          flash[:warning] = "Administrators cannot be permanently deleted.  If you truly wish to delete this user, remove their administrator role."
          format.html { redirect_to(users_path) }
          format.xml  { render :status => :unprocessable_entity }
        else
          User.transaction do
            id = @object.id
            @object.destroy
            create_change_log_entry(id)
          end
          format.html { redirect_to(users_path) }
          format.xml  { head :ok }
        end
      end
    end
  end
  
  def undelete
    User.transaction do
      @object.undelete!
      create_change_log_entry
    end
    respond_to do |format|
      format.html { redirect_to(users_path) }
      format.xml  { head :ok }
    end
  end
  
  # Checks for a user matching the activation code, and calls the activate
  # event for the user, if found.
  def activate
    logout_killing_session!
    @object = User.find_by_activation_code(params[:code]) unless params[:code].blank?
    respond_to do |format|
      case
      when !params[:code].blank? && @object && @object.current_state != :active
        @object.activate!
        create_change_log_entry(@object.id, @object.id, 'activate', 'User email activation.')
        flash[:notice] = "You're all signed up!  Please log in to continue."
        format.html { redirect_to(login_path) }
        format.xml  { head :ok }
      when params[:code].blank?
        flash[:error] = "Your activation code is missing.  Please follow the URL from your email."
        format.html { redirect_to(login_path) }
        format.xml  { render :status => :unprocessable_entity }
      else
        flash[:error] = "We couldn't find a user with that activation code -- check your email?  Or maybe you're already activated; try signing in."
        format.html { redirect_to(login_path) }
        format.xml  { render :status => :unprocessable_entity }
      end
    end
  end
  
  # Reset Password Routines...
  
  def forgot_password
  end
  
  def prepare_password_reset
    respond_to do |format|
      email = params[:email].blank? ? nil : params[:email].strip
      
      if email.blank?
        flash[:error] = "You must provide me with an email."
        format.html { redirect_to(forgot_password_path) }
        format.xml  { render :status => :unprocessable_entity }
      elsif (@object = User.find_by_email(email))
        case @object.current_state
        when :active, :forgetful
          @object.activate!
          @object.forget!
          create_change_log_entry(nil, @object.id, 'forgot', 'User forgot password.')
          flash[:notice] = "A password reset code has been sent to your email."
          format.html { redirect_to(login_path) }
          format.xml  { head :ok }
        else
          flash[:error] = "Sorry, but the account is not eligible for a password reset."
          format.html { redirect_to(forgot_password_path) }
          format.xml  { render :status => :unprocessable_entity }
        end # case
      else
        flash[:warning] = "No user could be found to match that email."
        format.html { redirect_to(forgot_password_path) }
        format.xml  { render :status => :unprocessable_entity }
      end # if
    end # format
  end # def
  
  def reset_password
    # Make sure we don't strip a nil value, but strip the code
    # in case the user copied some spaces.
    code = params[:code].nil? ? nil : params[:code].strip
    
    respond_to do |format|
      if @object = User.find_in_state(:first, :forgetful, :conditions => {:password_reset_code => code})
        format.html # reset_password.html.erb
        format.xml  { head :ok }
      else
        if code.nil?
          flash[:error] = "A password cannot be reset without a valid password reset code.  If yours has expired, please resetart the process."
        else
          flash[:error] = "No user was found to match that code (" + code + ").  Please check your email, or try again."
        end
        format.html { redirect_to(forgot_password_path) }
        format.xml  { render :status => :unprocessable_entity }
      end
    end
  end
  
  def do_reset
    # Make sure we don't strip a nil value, but strip the code
    # in case the user copied some spaces.
    code = params[:code].nil? ? nil : params[:code].strip
    # the user is not logged in, so we can't use the secure_find_user filter
    @object = User.find_in_state(:first, :forgetful, :conditions => {:password_reset_code => code})
    
    respond_to do |format|
      if @object.update_attributes(params[:user])
        @object.remember!
        flash[:notice] = 'Your password was successfully changed.  Please store it somewhere safe!'
        format.html { redirect_to(login_path) }
        format.xml  { head :ok }
      else
        flash[:error] = "There was a problem updating your user record.  Please try again."
        format.html { redirect_to forgot_password_path }
        format.xml  { render :xml => @object.errors, :status => :unprocessable_entity }
      end # if update
    end # respond_to
  end # def
  
  def suspend
    User.transaction do
      @object.suspend!
      create_change_log_entry
    end
    respond_to do |format|
      format.html { redirect_to(users_path) }
      format.xml  { head :ok }
    end
  end

  def unsuspend
    User.transaction do
      @object.unsuspend!
      create_change_log_entry
    end
    respond_to do |format|
      format.html { redirect_to(users_path) }
      format.xml  { head :ok }
    end
  end
  
  def account
    @object = current_user
    respond_to do |format|
      format.html { render :template => 'users/show' }
      format.xml  { render :xml => @object }
    end
  end
  
  def roles
    @available_roles = Role.find(:all).reject {|role| @object.roles.include?(role)}
  end
  
  def process_role
    case params[:commit]
    when 'Add role'
      role = Role.find_by_id(params[:role_id])
      @object.roles << role unless @object.roles.include?(role)
      @object.save(false)
      create_change_log_entry(nil, nil, 'add role', "Adding the '#{role.title}' role.")
    when 'Remove role'
      role = Role.find_by_id(params[:role_id])
      @object.roles.delete(role)
      @object.save(false)
      create_change_log_entry(nil, nil, 'remove role', "Removing the '#{role.title}' role.")
    end
    respond_to do |format|
      format.html { redirect_to(roles_user_path(@object)) }
      format.xml  { head :ok }
    end
  end
  
  # Makes sure the object is in the proper state for the requested action.
  def state_check(states)
    failed = false
    states = [states] unless states.is_a?(Array)
    unless states.include?(@object.current_state)
      flash[:error] = '<h2>Invalid state for action.</h2>The requested action requires the <code>[' + states.collect { |state| state.to_s }.join(' || ') + ']</code> state.'
      redirect_to(users_path)
    end
  end
  private :state_check
  
  def find_object
    if logged_in? && !params[:id].nil? && current_user.id != params[:id].to_i && !current_user.is_administrator?
      Proc.new { permission_denied }.call
    else
      @object = User.find_by_id(params[:id].to_i)
    end
  end
  protected :find_object
  
  def openid_consumer
    @openid_consumer ||= OpenID::Consumer.new(session, OpenID::Store::Filesystem.new("#{RAILS_ROOT}/tmp/openid"))
  end
  protected :openid_consumer
end
