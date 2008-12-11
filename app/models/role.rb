class Role < ActiveRecord::Base
  #################
  # ASSOCIATIONS
  has_and_belongs_to_many :users
  has_and_belongs_to_many :pages
  
  #################
  # VALIDATIONS

  validates_presence_of     :title
  validates_length_of       :title, :within => 2..40

  validates_presence_of     :description
  validates_length_of       :description, :within => 6..254


end
