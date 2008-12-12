class ContactCategory < ActiveRecord::Base
  #################
  # VALIDATIONS
  validates_presence_of     :title
  validates_length_of       :title, :within => 2..100
  
  validates_length_of       :email, :within => 5..150
  validates_format_of       :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => "appears invalid."
  
  def named_email
    return self.name.blank? ? self.email : "#{self.name} <#{self.email}>"
  end
end
