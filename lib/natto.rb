# Djn2ms module for configuration settings.
module Natto
  mattr_accessor :site_title              # Used in the title tag.
  mattr_accessor :host                    # Most notably, used by the authentication system.
  mattr_accessor :tango_home              # For locating tango icons in the application helper.
  mattr_accessor :max_violation_votes     # The maximum number of votes on a comment violation before it's hidden.
  mattr_accessor :small_image_size        # the size for thumbnails
  mattr_accessor :medium_image_size       # medium resize for attachment_fu
  mattr_accessor :large_image_size        # big stuff!
  mattr_accessor :portoflio_projects_max  # Max projects to display on portfolio pages

  self.site_title               = "Natto CMS"
  self.host                     = "localhost:3000"
  self.tango_home               = "/plugin_assets/natto/images/tango-icon-theme/"
  self.max_violation_votes      = 3
  self.portoflio_projects_max   = 15

  # image sizing
  self.small_image_size         = '80x80>'
  self.medium_image_size        = '300x'
  self.large_image_size         = '700x700>'
end
