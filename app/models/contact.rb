class Contact < Tableless
  column :email, :string
  column :name, :string
  column :message_type, :string
  column :message, :text
  
  validates_presence_of     :name, :message_type, :email, :message
  validates_length_of       :name, :within => 1..100, :if => :name_not_blank?
  validates_length_of       :message, :within => 10..999, :if => :message_not_blank?
  validates_length_of       :email, :within => 5..150, :if => :email_not_blank?
  validates_format_of       :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]+)\Z/i, :message => "appears invalid.", :if => :email_not_blank?
  
  def named_email
    return self.name.blank? ? self.email : "#{self.name} <#{self.email}>"
  end
  # Validation aid.
  def name_not_blank?
    !self.name.blank?
  end
  # Validation aid.
  def email_not_blank?
    !self.email.blank?
  end
  # Validation aid.
  def message_not_blank?
    !self.message.blank?
  end
end
