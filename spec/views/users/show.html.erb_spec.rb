require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/users/show.html.erb" do
  fixtures :users, :roles
  
  include UsersHelper
  
  before(:each) do
    @time = Time.now
    
    role = mock_model(Role)
    role.stub!(:title).twice.and_return("Role title")
    
    @object = mock_model(User)
    @object.stub!(:roles).and_return([role])
    @object.stub!(:first_name).and_return("First")
    @object.stub!(:last_name).and_return("Last")
    @object.stub!(:name).and_return("First Last")
    @object.stub!(:email).and_return("good@example_com")
    @object.stub!(:login).and_return("login")
    @object.stub!(:identity_url).and_return("http://djn2ms.myopenid.com/")
    @object.stub!(:activated_at).and_return(@time)
    @object.stub!(:created_at).and_return(@time)
    @object.stub!(:updated_at).and_return(@time)
    @object.stub!(:password_reset_at).and_return(@time)
    @object.stub!(:current_state).and_return(:active)
    
    assigns[:object] = @object
  end

  it "should render attributes" do
    render "/users/show.html.erb"
    response.should have_text(/First Last/)
    response.should have_text(/login/)
    response.should have_text(/good@example_com/)
    response.should have_text(/http:\/\/djn2ms\.myopenid\.com\//)
  end
end

