class Page < ActiveRecord::Base
  has_and_belongs_to_many :roles
  belongs_to :author, :class_name => "User", :foreign_key => "author_id"
  before_save   :sanitize_title
  before_create :set_author, :initialize_display_order
  
  #################
  # CONSTANTS
  NORMAL      = "Normal"
  BLOG        = "Blog"
  PORTFOLIO   = "Portfolio"
  BIOGRAPHY   = "Biography"
  # for select boxes
  TYPES       = [NORMAL, BLOG, PORTFOLIO, BIOGRAPHY]
  
  #################
  # VALIDATIONS

    #################
    # VALIDATION CONSTANTS

    RE_TITLE_OK      = /\A[^[:cntrl:]\\<>\/]*\z/
    MSG_TITLE_BAD   = "must not contain non-printing characters or \\&gt;&lt;&amp;/ please."

  validates_presence_of     :title
  validates_length_of       :title, :within => 2..40
  validates_format_of       :title, :with => RE_TITLE_OK, :message => MSG_TITLE_BAD
  
  validates_presence_of     :content,                 :if => :content_required?
  validates_length_of       :content, :minimum => 20, :if => :content_required?
  
  validates_presence_of     :description
  validates_length_of       :description, :within => 10..255
  
  #################
  # Allow modification via bulk-setters
  
  
  # Tree based page heirarchy
  acts_as_tree :order => 'display_order', :counter_cache => :child_count
  
  #################
  # Page states
  
  acts_as_state_machine :initial => :pending_review, :column => "aasm_state"
  
  state :pending_review,  :enter => :initialize_display_order
  state :approved,        :enter => :initialize_display_order
  state :published,       :enter => :initialize_display_order
  state :unpublished
  state :deleted,         :enter => :do_delete
  
  event :approve do
    transitions :from => :pending_review, :to => :approved
  end
  
  event :publish do
    transitions :from => [:approved, :unpublished], :to => :published
  end
  
  event :unpublish do
    transitions :from => :published, :to => :unpublished
  end
  
  event :delete do
    transitions :from => [:pending_review, :approved, :published, :unpublished], :to => :deleted
  end
  
  event :undelete do
    transitions :from => :deleted, :to => :pending_review
  end
  
  ###################################
  # Handle state transition events
  
  def do_delete
    self.display_order = nil
  end
  
  ####################################
  # Display order functions
  
  def self.max_display_order(page = nil)
    return nil if page.nil?
    max_page = Page.find(:first, :conditions => {:parent_id => page.parent_id}, :order => 'display_order DESC')
    
    if max_page.nil? || max_page.display_order.nil?
      return 0
    else
      max_page.display_order
    end
  end
  
  def self.min_display_order(page = nil)
    1
  end
  
  def is_max_display_order?
    self.display_order == Page.max_display_order(self)
  end
  
  def is_min_display_order?
    self.display_order == Page.min_display_order(self)
  end
  
  # Returns true when the page is either the home or admin page,
  # and otherwise returns false.
  def is_important?
    self.is_home_page? || self.is_admin_home_page?
  end
  
  # This is a utility function for setting a new parent node.
  def get_sibling_id(distance_above = 1)
    sibling_order = self.display_order - distance_above
    # so we can sub under the home page
    if distance_above == 1 && self.is_min_display_order? && self.parent_id.nil?
      if home = Page.find(:first, :conditions => {:is_home_page => true})
        return home.id
      end
    end
    # make sure it fits within the range of display orders
    return unless (Page.min_display_order(self)..Page.max_display_order(self)) === sibling_order
    # make sure there are even siblings to check
    return unless self.siblings.size > 0
    # finally, return an actual sibling id
    return Page.find(:first, :conditions => {:display_order => sibling_order, :parent_id => self.parent_id}).id
  end
  
  def content_required?
    advanced_path.blank?
  end
  
  def sanitize_title
    # this needs to check that it hasn't already been escaped
    self.title = self.title.gsub(/&/, '&amp;')
  end
  private :sanitize_title
  
  def set_author
    self.author = @current_user
  end
  private :set_author
  
  def initialize_display_order
    self.display_order = Page.max_display_order(self) + 1 if self.display_order.nil?
  end
  private :initialize_display_order
end
