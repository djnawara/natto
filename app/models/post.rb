class Post < NattoBase
  #################
  # ASSOCIATIONS
  has_and_belongs_to_many :media
  has_many    :comments
  belongs_to  :page
  
  #################
  # VALIDATIONS
  validates_presence_of     :page, :message => "must be selected"

  validates_presence_of     :title
  validates_length_of       :title, :within => 2..254

  validates_presence_of     :content
  
  attr_accessible :title, :description, :content, :page_id
  
  acts_as_state_machine :initial => :pending_review

  state :pending_review
  state :approved
  state :published,       :enter => :do_publish
  state :unpublished
  state :deleted

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
  
  def do_publish
    self.published_at = Time.now if self.published_at.nil?
  end
end
