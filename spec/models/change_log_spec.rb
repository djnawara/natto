require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ChangeLog do
  before(:each) do
    @change_log = ChangeLog.build!
  end

  it "should be valid" do
    @change_log.should be_valid
  end
end
