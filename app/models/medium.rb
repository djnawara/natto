class Medium < ActiveRecord::Base
  named_scope :parentless, :conditions => {:parent_id => nil}
  #################
  # CONSTANTS
  PRINT     = "Print"
  TV        = "Television"
  RADIO     = "Radio"
  DIGITAL   = "Digital"
  # for select boxes
  TYPES       = [PRINT, TV, RADIO, DIGITAL]
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
                 :thumbnails => { :thumb => Natto.small_image_size, :resized => Natto.medium_image_size, :large => Natto.large_image_size }

  validates_as_attachment
  
  def not_thumbnail?
    thumbnail.nil?
  end
  
  def self.mime_type(file = '')
    mime_types = { ".gif" => "image/gif", ".ief" => "image/ief", ".jpe" => "image/jpeg", ".jpeg" => "image/jpeg", ".jpg" => "image/jpeg", ".pbm" => "image/x-portable-bitmap", ".pgm" => "image/x-portable-graymap", ".png" => "image/png", ".pnm" => "image/x-portable-anymap", ".ppm" => "image/x-portable-pixmap", ".ras" => "image/cmu-raster", ".rgb" => "image/x-rgb", ".tif" => "image/tiff", ".tiff" => "image/tiff", ".xbm" => "image/x-xbitmap", ".xpm" => "image/x-xpixmap", ".xwd" => "image/x-xwindowdump" }
    mime_types[File.extname(file)]
  end
end
