class Comment < ActiveRecord::Base
  #################
  # ASSOCIATIONS
  belongs_to :post
  
  #################
  # VALIDATIONS
    #################
    # CONSTANTS
    RE_NAME_OK     = /\A[^[:cntrl:]\\<>\/&]*\z/              # Unicode, permissive
    MSG_NAME_BAD   = "must not contain non-printing characters or \\&gt;&lt;&amp;/ please."

  validates_presence_of     :name
  validates_length_of       :name, :within => 2..99
  validates_format_of       :name, :with => RE_NAME_OK, :message => MSG_NAME_BAD

  validates_presence_of     :content
  validates_length_of       :content, :within => 1..9999
end
