require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/pages/sitemap.html.erb" do
  include PagesHelper
  fixtures :pages
  
  before(:each) do
    @objects = [pages(:home), pages(:unsecured)]

    assigns[:objects] = @objects
  end

  it "should show the page title and content" do
    render "/pages/sitemap.html.erb"
    response.should have_tag("div[class=sitemap_node even]")
    response.should have_tag("div[class=sitemap_node odd]")
    response.should have_tag("a", "Home page")
    response.should have_tag("a", "Unsecured")
  end
end

