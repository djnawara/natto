# Include your configuration in this file (config/mail.yml)
DO_NOT_LIST = []
hidden_actions_list = YAML::load(File.open("#{RAILS_ROOT}/config/hide_from_js_nav.yml"))

hidden_actions_list.each do |title, hash|
  DO_NOT_LIST << hash
end