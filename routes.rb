ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes"
  
  # routes for resetting passwords
  do_reset        '/reset', :controller => 'users', :action => 'do_reset'
  reset_password  '/reset_password/:code', :controller => 'users', :action => 'reset_password', :conditions => {:method => :get}
  forgot_password '/forgot_password', :controller => 'users', :action => 'forgot_password',     :conditions => {:method => :get}
  
  #users
  activate    '/activate/:code', :controller => 'users', :action => 'activate',               :conditions => {:method => :get}
  signup      '/signup', :controller => 'users', :action => 'new',                            :conditions => {:method => :get}
  account     '/account', :controller => 'users', :action => 'account',                       :conditions => {:method => :get}
  
  # backups
  backups             '/backups', :controller => 'backups', :action => 'index',                 :conditions => {:method => :get}
  formatted_backups   '/backups.:format', :controller => 'backups', :action => 'index',         :conditions => {:method => :get}
  restore_backup      '/backups/restore/:id', :controller => 'backups', :action => 'restore',   :conditions => {:method => :get}
  destroy_backup      '/backups/destroy/:id', :controller => 'backups', :action => 'destroy',   :conditions => {:method => :delete}
  new_backup          '/backups/new', :controller => 'backups', :action => 'new',               :conditions => {:method => :get}
  download_backup     '/backups/download/:id', :controller => 'backups', :action => 'download', :conditions => {:method => :get}
  backup              '/backups/:id', :controller => 'backups', :action => 'show',              :conditions => {:method => :get}
  
  # sessions
  login   '/login', :controller => 'sessions', :action => 'new', :conditions => {:method => :get}
  logout  '/logout', :controller => 'sessions', :action => 'destroy'
  
  # admin routes
  admin           '/admin', :controller => 'pages', :action => 'admin'
  formatted_admin '/admin.:format', :controller => 'pages', :action => 'admin'
  
  # home routes
  connect '/home', :controller => 'pages', :action => 'home', :conditions => {:method => :get}
  connect '/home.:format', :controller => 'pages', :action => 'home', :conditions => {:method => :get}
  connect '/show', :controller => 'pages', :action => 'home'
  
  # pages
  show  '/show/:title/*args', :controller => 'pages', :action => 'show_by_title', :conditions => {:method => :get}
  
  # change_logs
  change_logs   '/change_logs', :controller => 'change_logs', :action => 'index',                       :conditions => {:method => :get}
  object_logs   '/change_logs/objects/:object_class', :controller => 'change_logs', :action => 'index', :conditions => {:method => :get}
  action_logs   '/change_logs/actions/:action_name', :controller => 'change_logs', :action => 'index',  :conditions => {:method => :get}
  instance_logs '/change_logs/instances/:object_class/:object_id', :controller => 'change_logs', :action => 'index'
  
  # posts (blog posts, news, etc)
  new_blog_post     '/posts/new/:page_id', :controller => 'posts', :action => 'new', :conditions => {:method => :get}
  feeds             '/feeds/:format', :controller => 'posts', :action => 'feeds', :conditions => {:method => :get}
  default_feed      '/feeds', :controller => 'posts', :action => 'feeds', :format => 'atom', :conditions => {:method => :get}
  
  # post comments
  new_post_comment  '/comments/new/:post_id', :controller => 'comments', :action => 'new', :conditions => {:method => :get}
  comment_violation '/comments/violation/:id', :controller => 'comments', :action => 'violation', :conditions => {:method => :get}
  
  # media
  image_version '/images/:id/:version', :controller => 'media', :action => 'show'
  image         '/images/:id', :controller => 'media', :action => 'show'
  batch         '/batch', :controller => 'media', :action => 'batch'
  run_batch     '/batch/run', :controller => 'media', :action => 'run_batch'
  
  # projects
  project_details           '/project/:id/:medium', :controller => 'projects', :action => 'show'
  project_details_default   '/project/:id', :controller => 'projects', :action => 'show'
  project_positions         '/projects/order', :controller => 'projects', :action => 'order'
  
  # biographies
  biography_details           '/biography/:id/:medium', :controller => 'biographies', :action => 'show'
  biography_details_default   '/biography/:id', :controller => 'biographies', :action => 'show'
  
  # OpenID
  complete_openid '/sessions/complete/', :controller => 'sessions', :action => 'complete', :conditions => {:method => :get}
  open_ids        '/sessions/get_registration_data/', :controller => 'sessions', :action => 'get_registration_data', :conditions => {:method => :post}
  
  # site map
  sitemap '/sitemap', :controller => 'pages', :action => 'sitemap', :conditions => {:method => :get}
  
  # pages and their relationships
  resources :pages, :member => {:set_display_order => :put, :roles => :get}
  
  # users and their relationships
  resources :users, :member => {:suspend => :put, :unsuspend => :put, :purge => :delete, :roles => :get}
  
  # projects and relationships
  resources :projects, :member => {:media => :get}
  
  # biographies and relationships
  resources :biographies, :member => {:media => :get}
  
  # map all of our objects
  resources :sessions, :roles, :posts, :comments, :media, :projects, :biographies
end
