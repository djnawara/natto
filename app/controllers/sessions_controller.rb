require 'openid'
require 'openid/store/filesystem'

class SessionsController < ApplicationController
  before_filter :not_logged_in_required, :only => [:new, :create, :complete]
  skip_before_filter :login_required, :only => [:new, :create, :complete]
  skip_before_filter :admin_required
  skip_before_filter :administrative_page
  
  IMMEDIATE_MODE = false
  LOGGED_IN_MESSAGE   = "You have successfully logged in."
  OID_NOT_REGISTERED  = "<h2>Unregistered OpenID</h2><p>That OpenId URL is valid, but not registered with our system.</p>"
  
  # render new.rhtml
  def new
  end
  
  # Starts a user session (log in)
  def create
    if !params[:openid_url].blank?
      begin
        openid_url = params[:openid_url]
        request = openid_consumer.begin(openid_url)
      rescue OpenID::OpenIDError => e
        flash[:error] = "Discovery failed for #{openid_url}: #{e}"
        redirect_to :action => 'new'
        return
      end
      # setup up the return URL
      return_to = url_for :action => 'complete', :only_path => false
      realm = root_url
      # this sends our OID request off to the OID server
      if request.send_redirect?(realm, return_to, IMMEDIATE_MODE)
        redirect_to request.redirect_url(realm, return_to, IMMEDIATE_MODE)
        return
      else
        render :text => request.html_markup(realm, return_to, IMMEDIATE_MODE, {'id' => 'openid_form'})
        return
      end
    else
      self.current_user = User.authenticate(params[:login], params[:password])
    end
    if logged_in?
      if params[:remember_me] == "1"
        current_user.remember_me unless current_user.remember_token?
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      flash[:notice] = LOGGED_IN_MESSAGE
      redirect_back_or_default
    else
      flash[:error] = "Invalid username and/or password." if flash[:error].blank?
      render :action => 'new'
    end
  end
  
  # Closes a user session (log out)
  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default
  end
  
  # After OpenID authentication, the OpenID response should redirect here.
  def complete
    current_url = url_for(:action => 'complete', :only_path => false)
    parameters = params.reject{|k,v|request.path_parameters[k]}
    response = openid_consumer.complete(parameters, current_url)
    
    case response.status
    when OpenID::Consumer::SUCCESS
      # now we need to test that this OID exists in our users table
      oid_user = User.find_by_identity_url(response.identity_url)
      if oid_user.nil?
        flash[:warning] = OID_NOT_REGISTERED
        redirect_to login_path, :identity_url => response.identity_url
      else
        flash[:notice] = LOGGED_IN_MESSAGE
        # This session variable means we're logged in with OID!
        session[:openid] = response.identity_url
        redirect_back_or_default
      end
      return
    when OpenID::Consumer::SETUP_NEEDED
      redirect_to response.setup_url
      return
    when OpenID::Consumer::CANCEL
      flash[:alert] = "OpenID transaction cancelled."
    end
    
    flash[:error] = "Could not log in with that OpenID."
    redirect_to login_path
  end
  
  def openid_consumer
    @openid_consumer ||= OpenID::Consumer.new(session,      
      OpenID::Store::Filesystem.new("#{RAILS_ROOT}/tmp/openid"))
  end
  protected :openid_consumer
end
