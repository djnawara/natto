namespace :sass do
  desc 'Updates stylesheets, if necessary, from their Sass templates.'
  task :update => :environment do
    # load other info from yaml config
    puts "Loading Sass config from RAILS_ROOT/config/sass.yml..."
    # Include your configuration in this file (config/sass.yml)
    sass_config = YAML::load(File.open("#{RAILS_ROOT}/config/sass.yml"))
    # Configure sass
    sass_config[RAILS_ENV].each do |key,value|
      # symbolize the style param, since Sass doesn't like us using a string
      Sass::Plugin.options[key.to_sym] = key.eql?("style") ? value.to_sym : value
    end
    # Use our plugin directories
    Sass::Plugin.options[:template_location] = File.join(RAILS_ROOT, "vendor", "plugins", "natto", "sass")
    Sass::Plugin.options[:css_location] = File.join(RAILS_ROOT, "vendor", "plugins", "natto", "assets", "stylesheets")
    puts "Generating stylesheet(s)..."
    puts "    #{Sass::Plugin.options[:template_location]}"
    Sass::Plugin.update_stylesheets
    puts "Done."
  end
end
