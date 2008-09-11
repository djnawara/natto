class Medium < ActiveRecord::Base
  #################
  # ASSOCIATIONS
  has_and_belongs_to_many :widgets
  
  #################
  # VALIDATIONS

    #################
    # CONSTANTS

  validates_presence_of     :location
  validates_length_of       :location, :within => 2..254

  validates_presence_of     :type
  validates_length_of       :type, :within => 1..254
end
