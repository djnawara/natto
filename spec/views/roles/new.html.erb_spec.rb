require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/roles/new.html.erb" do
  before(:each) do
    @object = mock_model(Role)
    @object.stub!(:new_record?).and_return(true)
    @object.stub!(:title).and_return("MyString")
    @object.stub!(:description).and_return("MyText")
    assigns[:object] = @object
  end

  it "should render new form" do
    render "/roles/form.html.erb"
    
    response.should have_tag("form[action=?][method=post]", roles_path) do
      with_tag("input#role_title[name=?]", "role[title]")
      with_tag("textarea#role_description[name=?]", "role[description]")
    end
  end
end


