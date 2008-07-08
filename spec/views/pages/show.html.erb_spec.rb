require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/pages/show.html.erb" do
  include PagesHelper
  
  before(:each) do
    @object = mock_model(Page)
    @object.stub!(:title).and_return("Title")
    @object.stub!(:content).and_return("content")

    assigns[:object] = @object
  end

  it "should show the page title and content" do
    render "/pages/show.html.erb"
    response.should have_tag("h1", "Title")
    response.should have_text(/content/)
  end
end

