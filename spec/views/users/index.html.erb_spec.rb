require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/users/index.html.erb" do
  include UsersHelper
  
  before(:each) do
    user_98 = mock_model(User)
    user_98.should_receive(:name).and_return("First Last")
    user_98.should_receive(:email).and_return("myemail")
    user_98.should_receive(:login).exactly(3).times.and_return("login")
    user_98.should_receive(:identity_url).and_return("identity")
    user_98.should_receive(:current_state).exactly(7).times.and_return(:active)
    
    user_99 = mock_model(User)
    user_99.should_receive(:name).and_return("First Last")
    user_99.should_receive(:email).and_return("myemail")
    user_99.should_receive(:login).exactly(2).times.and_return("login")
    user_99.should_receive(:identity_url).and_return("identity")
    user_99.should_receive(:current_state).exactly(7).times.and_return(:passive)

    assigns[:objects] = [user_98, user_99]
  end

  it "should render list of users" do
    render "/users/index.html.erb"
    response.should have_tag("tr>td>a", "First Last", 2)
    response.should have_tag("tr>td", "login", 2)
    response.should have_tag("tr>td", "identity", 2)
    response.should have_tag("tr>td", "Passive", 2)
    response.should have_tag("tr>td", "Active", 2)
  end
end

