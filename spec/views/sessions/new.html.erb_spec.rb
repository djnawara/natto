require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/sessions/new" do
  before(:each) do
    render 'sessions/new'
  end
  
  #Delete this example and add some real ones or delete this file
  it "should have a login form with a 'remember me' checkbox" do
    response.should have_tag('label[for=login]')
    response.should have_tag('label[for=password]')
    response.should have_tag('label[for=remember_me]')
    response.should have_tag('label[for=openid_url]')
    
    response.should have_tag('input')
  end
  
  it "should provide links for 'forgot password' and 'signup' forms" do
    response.should have_tag('a[href=' + forgot_password_path + ']')
    response.should have_tag('a[href=' + signup_path + ']')
  end
end
