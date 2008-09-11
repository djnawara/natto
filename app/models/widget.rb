class Widget < ActiveRecord::Base
  #################
  # ASSOCIATIONS
  has_and_belongs_to_many :media
  
  #################
  # VALIDATIONS

    #################
    # CONSTANTS
  
    RE_TITLE_OK     = /\A[^[:cntrl:]\\<>\/&]*\z/              # Unicode, permissive
    MSG_TITLE_BAD   = "must not contain non-printing characters or \\&gt;&lt;&amp;/ please."

  validates_presence_of     :title
  validates_length_of       :title, :within => 2..40
  validates_format_of       :title, :with => RE_TITLE_OK, :message => MSG_TITLE_BAD

  validates_presence_of     :description
  validates_length_of       :description, :within => 6..254

  validates_presence_of     :content
  validates_length_of       :content, :within => 1..9999
end
