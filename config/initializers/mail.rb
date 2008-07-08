
# Include your configuration in this file (config/mail.yml)
mail_config = YAML::load(File.open("#{RAILS_ROOT}/config/mail.yml"))

ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.delivery_method = mail_config[RAILS_ENV]['delivery_method']

# setup sendmail to send ASAP
ActionMailer::Base.sendmail_settings = {
  :arguments      => mail_config[RAILS_ENV]['sendmail_settings'][:arguments]
}

# setup action mailer SMTP settings
ActionMailer::Base.smtp_settings = {
  :address        => mail_config[RAILS_ENV]['smtp_settings']['address'],
  :port           => mail_config[RAILS_ENV]['smtp_settings']['port'],
  :domain         => mail_config[RAILS_ENV]['smtp_settings']['domain'],
  :authentication => mail_config[RAILS_ENV]['smtp_settings']['authentication'],
  :user_name      => mail_config[RAILS_ENV]['smtp_settings']['username'],
  :password       => mail_config[RAILS_ENV]['smtp_settings']['password']
}

# default recipient for email
DEFAULT_RECIPIENT = mail_config[RAILS_ENV]['default_recipient'] unless defined? DEFAULT_RECIPIENT
DEFAULT_FROM = mail_config[RAILS_ENV]['default_from'] unless defined? DEFAULT_FROM
