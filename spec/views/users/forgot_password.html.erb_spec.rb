require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/forgot_password" do
  before(:each) do
    render '/users/forgot_password'
  end
  
  #Delete this example and add some real ones or delete this file
  it "should have a form with an email input" do
    response.should have_tag('label[for=email]')
    response.should have_tag('input[id=email]')
    
    response.should have_tag('label', :count => 1)
    response.should have_tag('input', :count => 2)
  end
end
