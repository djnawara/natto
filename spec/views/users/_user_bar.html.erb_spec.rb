require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "partial 'user_bar'" do
  fixtures :users, :roles
  
  describe "when logged in" do
    it "should provide profile and logout links" do
      login_as :admin
      render "/users/_user_bar.html.erb"
    
      response.should have_tag("div[id=user_bar]") do
        with_tag("a[href=?]", '/account')
        with_tag("a[href=?]", '/logout')
      end
    end
  end
  
  describe "when logged out" do
    it "should provide login and register links" do
      render "/users/_user_bar.html.erb"
    
      response.should have_tag("div[id=user_bar]") do
        with_tag("a[href=?]", '/signup')
        with_tag("a[href=?]", '/login')
      end
    end
  end
end


