class Project < ActiveRecord::Base
  named_scope :active, :order => :position, :limit => Natto.portoflio_projects_max
  named_scope :extras, :conditions => ['position > ?', Natto.portoflio_projects_max], :order => :position
  
  #################
  # ASSOCIATIONS
  has_and_belongs_to_many :media
  
  #################
  # VALIDATIONS
  validates_presence_of     :title
  validates_length_of       :title, :within => 2..40

  validates_presence_of     :client
  validates_length_of       :client, :within => 2..40
end
