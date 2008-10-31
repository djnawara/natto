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

  has_attachment :storage     => :file_system, 
                 :max_size    => 5.megabytes,
                 :path_prefix => "public/media",
                 :partition   => false,
                 :thumbnails => { :thumb => Natto.small_image_size, :resized => Natto.medium_image_size, :large => Natto.large_image_size }

  validates_as_attachment

  attr_accessible :title, :url, :description, :medium_type, :uploaded_data, :content_type, :filename, :temp_path, :thumbnail_resize_options

  def not_thumbnail?
    thumbnail.nil?
  end
  
  def self.mime_type(file = '')
    mime_types = { ".gif" => "image/gif", ".ief" => "image/ief", ".jpe" => "image/jpeg", ".jpeg" => "image/jpeg", ".jpg" => "image/jpeg", ".pbm" => "image/x-portable-bitmap", ".pgm" => "image/x-portable-graymap", ".png" => "image/png", ".pnm" => "image/x-portable-anymap", ".ppm" => "image/x-portable-pixmap", ".ras" => "image/cmu-raster", ".rgb" => "image/x-rgb", ".tif" => "image/tiff", ".tiff" => "image/tiff", ".xbm" => "image/x-xbitmap", ".xpm" => "image/x-xpixmap", ".xwd" => "image/x-xwindowdump" }
    mime_types[File.extname(file)]
  end
  
  # overridden to store thumbs in their own directory
  def full_filename(thumbnail = nil)
    file_system_path = (thumbnail ? thumbnail_class : self).attachment_options[:path_prefix].to_s
    if thumbnail.blank? && self.thumbnail.blank?
      File.join(RAILS_ROOT, file_system_path, *partitioned_path(thumbnail_name_for(thumbnail)))
    else
      File.join(RAILS_ROOT, file_system_path, (thumbnail.blank? ? self.thumbnail.to_s : thumbnail.to_s), *partitioned_path(thumbnail_name_for(thumbnail)))
    end
  end
  
  # Gets the thumbnail name for a filename.  'foo.jpg' becomes 'foo_thumbnail.jpg'
  def thumbnail_name_for(thumbnail = nil)
    return filename
  end
end
