require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/roles/index.html.erb" do
  before(:each) do
    role_98 = mock_model(Role)
    role_98.should_receive(:title).twice.and_return("Role Title")
    role_98.should_receive(:description).and_return("Role description is short.")
    role_99 = mock_model(Role)
    role_99.should_receive(:title).twice.and_return("Role Title")
    role_99.should_receive(:description).and_return("Second role description.")

    assigns[:objects] = [role_98, role_99]
  end

  it "should render list of roles" do
    render "/roles/index.html.erb"
    response.should have_tag("tr>td", "Role Title", 2)
    response.should have_tag("tr>td", "Role description is short.")
    response.should have_tag("tr>td", "Second role description.")
  end
end

