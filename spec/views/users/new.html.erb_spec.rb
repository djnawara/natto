require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/users/new.html.erb" do
  include UsersHelper
  
  describe "as a guest user, not logged in" do
    before(:each) do
      @object = mock_model(User)
      @object.stub!(:roles).and_return([])
      @object.stub!(:new_record?).and_return(true)
      @object.stub!(:first_name).and_return("First Name")
      @object.stub!(:last_name).and_return("Last Name")
      @object.stub!(:name).and_return("First Name Last Name")
      @object.stub!(:email).and_return("good@example.com")
      @object.stub!(:new_email).and_return("")
      @object.stub!(:login).and_return("login")
      @object.stub!(:identity_url).and_return("openid")
      @object.stub!(:password).and_return("new_password")
      @object.stub!(:password_confirmation).and_return("new_password")
      @object.stub!(:password=).and_return(nil)
      @object.stub!(:password_confirmation=).and_return(nil)
      @object.stub!(:current_state).and_return(:active)
      @object.stub!(:has_role?).and_return(true)
      assigns[:object] = @object
    end

    it "should render new form" do
      render "/users/form.html.erb"

      response.should have_tag("form[action=?][method=post]", users_path) do
        with_tag("input#user_first_name[name=?]", "user[first_name]")
        with_tag("input#user_last_name[name=?]", "user[last_name]")
        with_tag("input#user_email[name=?]", "user[email]")
        with_tag("input#user_login[name=?]", "user[login]")
        with_tag("input#user_identity_url[name=?]", "user[identity_url]")
      end
    end
  end
end


