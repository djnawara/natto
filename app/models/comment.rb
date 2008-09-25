class Comment < ActiveRecord::Base
  #################
  # ASSOCIATIONS
  belongs_to :post
  
  #################
  # VALIDATIONS
    #################
    # CONSTANTS
    RE_TITLE_OK     = /\A[^[:cntrl:]\\<>\/&]*\z/              # Unicode, permissive
    MSG_TITLE_BAD   = "must not contain non-printing characters or \\&gt;&lt;&amp;/ please."

  validates_presence_of     :commentor
  validates_length_of       :commentor, :within => 2..99
  validates_format_of       :commentor, :with => RE_TITLE_OK, :message => MSG_TITLE_BAD

  validates_presence_of     :content
  validates_length_of       :content, :within => 1..9999
end
