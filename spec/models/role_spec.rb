require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Role do
  before(:each) do
    @role = Role.build!
  end

  it "should be valid" do
    @role.should be_valid
  end
end
