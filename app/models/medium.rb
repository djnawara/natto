class Medium < ActiveRecord::Base
  #################
  # CONSTANTS
  PRINT     = "Print"
  TV        = "Television"
  RADIO     = "Radio"
  DIGITAL   = "Digital"
  # for select boxes
  TYPES       = [PRINT, TV, RADIO, DIGITAL]
  # for image sizes
  THUMB   = '80x80>'
  MEDIUM  = '300x'
  LARGE   = '700x700>'

  #################
  # ASSOCIATIONS
  
  # TODO: Make this polymorphic!!
  has_and_belongs_to_many :posts
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :biographies

  #################
  # VALIDATIONS
  validates_presence_of   :medium_type, :if => :not_thumbnail?

  has_attachment :processor   => :MiniMagick,
                 :storage     => :file_system, 
                 :max_size    => 5.megabytes,
                 :path_prefix => "public/media",
                 :partition   => false,
                 :thumbnails => { :thumb => THUMB, :resized => MEDIUM, :large => LARGE }

  validates_as_attachment
  
  def not_thumbnail?
    thumbnail.nil?
  end
end
