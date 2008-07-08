require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SessionsController do
  fixtures :users
  
  it "should login and redirect" do
    post :create, :login => 'active_non_admin', :password => 'foobar'
    session[:user_id].should_not == nil
    response.should be_redirect
  end
  
  it "should not redirect on failed login" do
    post :create, :login => 'active_non_admin', :password => 'wrong password'
    session[:user_id].should == nil
    response.should be_success
    response.should_not be_redirect
  end
  
  it "should log out" do
    login_as :active_non_admin
    get :destroy
    session[:user_id].should == nil
  end
  
  it "should remember me" do
    post :create, :login => 'active_non_admin', :password => 'foobar', :remember_me => "1"
    response.cookies["auth_token"].should_not == nil
  end
  
  it "should not remember me" do
    post :create, :login => 'active_non_admin', :password => 'foobar', :remember_me => "0"
    response.cookies["auth_token"].should == nil
  end
  
  it "should delete cookie on logout" do
    login_as :active_non_admin
    get :destroy
    response.cookies["auth_token"].should == []
  end
  
  it "should log in with cookie" do
    users(:active_non_admin).remember_me
    request.cookies["auth_token"] = cookie_for(:active_non_admin)
    get :new
    controller.send(:logged_in?).should be_true
  end
  
  it "should fail expired cookie login" do
    users(:active_non_admin).remember_me
    users(:active_non_admin).update_attribute :remember_token_expires_at, 5.minutes.ago
    request.cookies["auth_token"] = cookie_for(:active_non_admin)
    get :new
    controller.send(:logged_in?).should_not be_true
  end
  
  def auth_token(token)
    CGI::Cookie.new('name' => 'auth_token', 'value' => token)
  end
  private :auth_token
  
  def cookie_for(user)
    auth_token users(user).remember_token
  end
  private :cookie_for
end
