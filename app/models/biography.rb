class Biography < ActiveRecord::Base
  #################
  # ASSOCIATIONS
  has_and_belongs_to_many :media
  
  #################
  # VALIDATIONS

  validates_presence_of     :job_title
  validates_length_of       :job_title, :within => 2..254

  validates_presence_of     :content
end
