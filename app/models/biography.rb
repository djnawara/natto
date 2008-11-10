class Biography < ActiveRecord::Base
  #################
  # ASSOCIATIONS
  has_and_belongs_to_many :media
  
  #################
  # VALIDATIONS

    #################
    # CONSTANTS
  
    RE_TITLE_OK     = /\A[^[:cntrl:]\\<>\/&]*\z/              # Unicode, permissive
    MSG_TITLE_BAD   = "must not contain non-printing characters or \\&gt;&lt;&amp;/ please."

  validates_presence_of     :job_title
  validates_length_of       :job_title, :within => 2..254
  validates_format_of       :job_title, :with => RE_TITLE_OK, :message => MSG_TITLE_BAD

  validates_presence_of     :content
end
