# Include your configuration in this file (config/sass.yml)
sass_config = YAML::load(File.open("#{RAILS_ROOT}/config/sass.yml"))
# Configure sass
sass_config[RAILS_ENV].each do |key,value|
  # symbolize the style param, since Sass doesn't like us using a string
  Sass::Plugin.options[key.to_sym] = key.eql?("style") ? value.to_sym : value
end