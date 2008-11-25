class Medium < ActiveRecord::Base
  named_scope :parentless, :conditions => {:parent_id => nil}
  #################
  # CONSTANTS
  PRINT     = "Print"
  TV        = "Television"
  RADIO     = "Radio"
  DIGITAL   = "Digital"
  OTHER     = "Other"
  # for select boxes
  TYPES       = [PRINT, TV, RADIO, DIGITAL, OTHER]
  # SIZES
  SMALL     = "thumb"
  MEDIUM    = "resized"
  LARGE     = "large"
  #################
  # ASSOCIATIONS
  
  # TODO: Make this polymorphic!!
  has_and_belongs_to_many :posts
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :biographies

  #################
  # VALIDATIONS
  has_attachment :processor   => 'MiniMagick',
                 :storage     => :file_system, 
                 :max_size    => 5.megabytes,
                 :path_prefix => "public/media",
                 :partition   => true,
                 :thumbnails  => Natto.media_thumbnails_hash

  validates_as_attachment

  attr_accessible :alt_text, :uploaded_data, :content_type, :filename, :temp_path, :thumbnail_resize_options

  def not_thumbnail?
    thumbnail.nil?
  end
  
  def self.mime_type(file = '')
    mime_types = { ".gif" => "image/gif", ".ief" => "image/ief", ".jpe" => "image/jpeg", ".jpeg" => "image/jpeg", ".jpg" => "image/jpeg", ".pbm" => "image/x-portable-bitmap", ".pgm" => "image/x-portable-graymap", ".png" => "image/png", ".pnm" => "image/x-portable-anymap", ".ppm" => "image/x-portable-pixmap", ".ras" => "image/cmu-raster", ".rgb" => "image/x-rgb", ".tif" => "image/tiff", ".tiff" => "image/tiff", ".xbm" => "image/x-xbitmap", ".xpm" => "image/x-xpixmap", ".xwd" => "image/x-xwindowdump" }
    mime_types[File.extname(file)]
  end
  
  def uploaded_data=(file_data)
    return nil if file_data.nil? || file_data.size == 0
    self.content_type = file_data.content_type
    extension = file_data.original_filename.slice(/\.\w+$/)
    # generate a random filename to avoid conflicts
    rand = Digest::SHA1.hexdigest(Time.now.to_s)
    rand = rand[0,14] if rand.length > 15
    self.filename = "#{rand}#{extension}"
    File.extname(file_data.original_filename) if respond_to?(:filename)
    if file_data.is_a?(StringIO)
      file_data.rewind
      self.temp_data = file_data.read
    else
      self.temp_path = file_data.path
    end
  end
  
  def is_image?
    self.content_type.include?("image")
  end
  
  def is_video?
    self.content_type.include?("video")
  end
  
  def is_audio?
    self.content_type.include?("audio")
  end
end
