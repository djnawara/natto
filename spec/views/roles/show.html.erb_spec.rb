require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/roles/show.html.erb" do
  before(:each) do
    @object = mock_model(Role)
    @object.stub!(:title).and_return("MyString")
    @object.stub!(:description).and_return("MyText")

    assigns[:object] = @object
  end

  it "should render attributes in <p>" do
    render "/roles/show.html.erb"
    response.should have_text(/MyString/)
    response.should have_text(/MyText/)
  end
end

