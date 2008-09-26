# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  helper :application, :users, :pages, :posts # include these helpers all the time
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '73195d1cdc5b26a20c8a62fda7f8d982'
  # lock _everything_ down by default
  before_filter :login_required, :admin_required
  # This flags admin pages in navigation by dumping the parent node
  # into the @page variable.
  before_filter :administrative_page, :only => [:index, :new, :create, :edit, :update, :destroy, :purge, :admin, :restore]
  def administrative_page
    @page = Page.find_by_title(params[:controller].capitalize) || Page.find_by_is_admin_home_page(true)
  end
  private :administrative_page
  #don't render template for xmlhttp request.
  def render(*args)
    args.first[:layout] = false if request.xhr? and args.first[:layout].nil?
    super
  end
end
