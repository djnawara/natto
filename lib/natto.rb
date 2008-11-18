# Djn2ms module for configuration settings.
module Natto
  mattr_accessor :site_title              # Used in the title tag.
  mattr_accessor :host                    # Most notably, used by the authentication system.
  mattr_accessor :tango_home              # For locating tango icons in the application helper.
  mattr_accessor :max_violation_votes     # The maximum number of votes on a comment violation before it's hidden.
  mattr_accessor :small_image_size        # the size for thumbnails
    mattr_accessor :small_image_width
    mattr_accessor :small_image_height
  mattr_accessor :medium_image_size       # medium resize for attachment_fu
    mattr_accessor :medium_image_width
    mattr_accessor :medium_image_height
  mattr_accessor :large_image_size        # big stuff!
    mattr_accessor :large_image_width
    mattr_accessor :large_image_height
  mattr_accessor :croppable_image_size    # never used except when cropping others
    mattr_accessor :croppable_image_width
    mattr_accessor :croppable_image_height
  mattr_accessor :media_thumbnails_hash   # holds all thumbnail settings
  mattr_accessor :portoflio_projects_max  # Max projects to display on portfolio pages

  self.site_title               = "Natto CMS"
  self.host                     = "localhost:3000"
  self.tango_home               = "/plugin_assets/natto/images/tango-icon-theme/"
  self.max_violation_votes      = 3
  self.portoflio_projects_max   = 15

  # image sizing
  self.small_image_width        = '80'
  self.small_image_height       = '80'
  self.small_image_size         = "#{self.small_image_width}x#{self.small_image_height}!"
  
  self.medium_image_width       = '300'
  self.medium_image_height      = ''
  self.medium_image_size        = "#{self.medium_image_width}x#{self.medium_image_height}"
  
  self.large_image_width        = '700'
  self.large_image_height       = '700'
  self.large_image_size         = "#{self.large_image_width}x#{self.large_image_height}>"
  
  self.croppable_image_width    = '500'
  self.croppable_image_height   = '700'
  self.croppable_image_size     = "#{self.croppable_image_width}x#{self.croppable_image_height}>"

  self.media_thumbnails_hash    = { :thumb => self.small_image_size,
                                    :resized => self.medium_image_size,
                                    :large => self.large_image_size,
                                    :croppable => self.croppable_image_size }
end
