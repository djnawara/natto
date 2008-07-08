require 'digest/sha1'
require 'ftools'
# meh
RAILS_ROOT              = File.join('..', '..', '..')
# We need to remove the application.rb and application_helper.rb files
# which rails created.
application_controller  = File.join(RAILS_ROOT, 'app', 'controllers', 'application.rb')
application_helper      = File.join(RAILS_ROOT, 'app', 'helpers', 'application_helper.rb')
# Let's also delete rails.png and index.html.
index_html              = File.join(RAILS_ROOT, 'public', 'index.html')
rails_png               = File.join(RAILS_ROOT, 'public', 'images', 'rails.png')
# Do the actual deleting
File.delete(application_controller) if File.exists?(application_controller)
File.delete(application_helper)     if File.exists?(application_helper)
File.delete(index_html)             if File.exists?(index_html)
File.delete(rails_png)              if File.exists?(rails_png)
# Time to create our site keys
site_keys_initializer         = File.join('config', 'initializers', 'site_keys.rb')
File.open(site_keys_initializer, 'w+') do |site_keys_rb|
  site_keys_rb.syswrite("# Look at User.password_digest to see how this is used.

# A Site key gives additional protection against a dictionary attack if your
# DB is ever compromised.  With no site key, we store
#   DB_password = hash(user_password, DB_user_salt)
# If your database were to be compromised you'd be vulnerable to a dictionary
# attack on all your stupid users' passwords.  With a site key, we store
#   DB_password = hash(user_password, DB_user_salt, Code_site_key)
# That means an attacker needs access to both your site's code *and* its
# database to mount an \"offline dictionary attack.\":http://www.dwheeler.com/secure-programs/Secure-Programs-HOWTO/web-authentication.html
# 
# It's probably of minor importance, but recommended by best practices: 'defense
# in depth'.  Needless to say, if you upload this to github or the youtubes or
# otherwise place it in public view you'll kinda defeat the point.  Your users'
# passwords are still secure, and the world won't end, but defense_in_depth -= 1.
# 
# Please note: if you change this, all the passwords will be invalidated, so DO
# keep it someplace secure.  Use the random value given or type in the lyrics to
# your favorite Jay-Z song or something; any moderately long, unpredictable text.
")
  site_keys_rb.syswrite('REST_AUTH_SITE_KEYS = "' + Digest::SHA1.hexdigest([Time.now, (1..10).map{ rand.to_s }].flatten.join('--')) + '"')
  site_keys_rb.syswrite("
# Repeated applications of the hash make brute force (even with a compromised
# database and site key) harder, and scale with Moore's law.
#
#   bq. \"To squeeze the most security out of a limited-entropy password or
#   passphrase, we can use two techniques [salting and stretching]... that are
#   so simple and obvious that they should be used in every password system.
#   There is really no excuse not to use them.\":http://tinyurl.com/37lb73
#   Practical Security (Ferguson & Scheier) p350
# 
# A modest 10 foldings (the default here) adds 3ms.  This makes brute forcing 10
# times harder, while reducing an app that otherwise serves 100 reqs/s to 78 signin
# reqs/s, an app that does 10reqs/s to 9.7 reqs/s
# 
# More:
# * http://www.owasp.org/index.php/Hashing_Java
# * \"An Illustrated Guide to Cryptographic Hashes\":http://www.unixwiz.net/techtips/iguide-crypto-hashes.html
REST_AUTH_DIGEST_STRETCHES = 10
")
end

# Now let's copy some configuration files to the main application.
config_destination            = File.join(RAILS_ROOT, 'config')
initializer_destination       = File.join(config_destination, 'initializers')
mail_config                   = File.join('config', 'mail.yml')
mail_initializer              = File.join('config', 'initializers', 'mail.rb')
hide_from_js_nav_config       = File.join('config', 'hide_from_js_nav.yml')
hide_from_js_nav_initializer  = File.join('config', 'initializers', 'hide_from_js_nav.rb')
# Do the actual copying...
File.copy(mail_config,                  File.join(config_destination,       'mail.yml'))              if File.exists?(mail_config)
File.copy(mail_initializer,             File.join(initializer_destination,  'mail.rb'))               if File.exists?(mail_initializer)
File.copy(hide_from_js_nav_config,      File.join(config_destination,       'hide_from_js_nav.yml'))  if File.exists?(hide_from_js_nav_config)
File.copy(hide_from_js_nav_initializer, File.join(initializer_destination,  'hide_from_js_nav.rb'))   if File.exists?(hide_from_js_nav_initializer)
File.copy(site_keys_initializer,        File.join(initializer_destination,  'site_keys.rb'))          if File.exists?(site_keys_initializer)
# Make our backup folder
backups = File.join(RAILS_ROOT, 'backups')
Dir.mkdir(backups) unless File.directory?(backups)