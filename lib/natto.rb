# Djn2ms module for configuration settings.
module Natto
  mattr_accessor :site_title            # Used in the title tag.
  mattr_accessor :host                  # Most notably, used by the authentication system.
  mattr_accessor :tango_home            # For locating tango icons in the application helper.
  mattr_accessor :max_violation_votes   # The maximum number of votes on a comment violation before it's hidden.
  
  self.site_title               = "Natto CMS"
  self.host                     = "localhost:3000"
  self.tango_home               = "/plugin_assets/natto/images/tango-icon-theme/"
  self.max_violation_votes      = 3
end
