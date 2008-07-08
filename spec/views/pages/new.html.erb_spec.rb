require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/pages/new.html.erb" do
  include PagesHelper
  
  before(:each) do
    @object = mock_model(Page)
    @object.stub!(:new_record?).and_return(true)
    @object.stub!(:title).and_return("MyString")
    @object.stub!(:description).and_return("MyText")
    @object.stub!(:content).and_return("MyText")
    @object.stub!(:display_order).and_return("1")
    @object.stub!(:author_id).and_return("1")
    @object.stub!(:is_home_page).and_return(false)
    @object.stub!(:is_admin_home_page).and_return(false)
    @object.stub!(:advanced_path).and_return(nil)
    @object.stub!(:parent_id).and_return(nil)
    assigns[:object] = @object
  end

  it "should render new form" do
    render "/pages/form.html.erb"
    
    response.should have_tag("form[action=?][method=post]", pages_path) do
      with_tag("input#page_title[name=?]", "page[title]")
      with_tag("textarea#page_description[name=?]", "page[description]")
      with_tag("textarea#page_content[name=?]", "page[content]")
      with_tag("input#page_is_home_page[name=?]", "page[is_home_page]")
      with_tag("input#page_is_admin_home_page[name=?]", "page[is_admin_home_page]")
    end
  end
end


