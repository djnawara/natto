class Post < NattoBase
  #################
  # ASSOCIATIONS
  has_and_belongs_to_many :media
  has_many    :comments
  belongs_to  :page
  
  #################
  # VALIDATIONS
    #################
    # CONSTANTS
    RE_TITLE_OK     = /\A[^[:cntrl:]\\<>\/&]*\z/              # Unicode, permissive
    MSG_TITLE_BAD   = "must not contain non-printing characters or \\&gt;&lt;&amp;/ please."

  validates_presence_of     :title
  validates_length_of       :title, :within => 2..40
  validates_format_of       :title, :with => RE_TITLE_OK, :message => MSG_TITLE_BAD

  validates_presence_of     :content
  validates_length_of       :content, :within => 1..9999

  # Return the object's uber-parent.
  def get_root_ancestor
    if parent_id.nil? || parent_type.nil?
      return self
    else
      parent = parent_type.constantize.find_by_id(parent_id)
      return if parent.nil?
      return parent if !parent.class.name.eql?(self.class.name)
      return parent.get_root_ancestor
    end
  end
end
