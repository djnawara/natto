class Contact < Tableless
  column :email, :string
  column :name, :string
  column :message_type, :string
  column :message, :text
  
  validates_presence_of     :name, :message_type, :email, :message
  validates_length_of       :name, :within => 1..100
  validates_length_of       :message, :within => 10..999
  validates_length_of       :email, :within => 5..150
  validates_format_of       :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]+)\Z/i, :message => "appears invalid."
  
  def named_email
    return self.name.blank? ? self.email : "#{self.name} <#{self.email}>"
  end
end
