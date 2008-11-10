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
  validates_length_of       :title, :within => 2..254
  validates_format_of       :title, :with => RE_TITLE_OK, :message => MSG_TITLE_BAD

  validates_presence_of     :content
  
  attr_accessible :title, :description, :content, :page_id
end
