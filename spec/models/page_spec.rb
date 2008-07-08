require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Page do
  fixtures :pages
  
  it "should be important if the home or admin page" do
    @page = Page.build! :is_home_page => true
    @page.is_important?.should == true
    
    @page = Page.build! :is_admin_home_page => true
    @page.is_important?.should == true
  end
  
  it "should not be important unless the home or admin page" do
    @page = Page.build!({:is_home_page => false, :is_admin_home_page => false})
    @page.is_important?.should == false
  end
  
  it "should have a min/max display orders relative to siblings" do
    @page = pages(:secured)
    @page.display_order.should == 1
    @page.is_min_display_order?.should == true
    @page.is_max_display_order?.should == false
    Page.max_display_order(@page).should == 4
    @page = pages(:pending_review)
    @page.display_order.should == 4
    @page.is_max_display_order?.should == true
  end
  
  it "should give the id of siblings based on display_order" do
    @page = pages(:unsecured)
    @sibling_above = pages(:secured)
    @sibling_below = pages(:approved)
    @page.get_sibling_id(1).should == @sibling_above.id
    @page.get_sibling_id(-1).should == @sibling_below.id
    @sibling_above.display_order.should == 1
    (@sibling_above.is_min_display_order? && @sibling_above.parent_id.nil?).should == true
    @sibling_above.get_sibling_id(1).should == pages(:home).id
  end
  
  it "should return 0 no siblings have a display order" do
    @page = pages(:child)
    @page.delete!
    Page.max_display_order(@page).should == 0
  end
  
  describe "being created" do
    it "should change the page count" do
      lambda {
        @page = Page.build!
      }.should change(Page, :count).by(1)
    end

    it "should be valid" do
      @page = Page.build!
      @page.should be_valid
    end
    
    it "should require a title" do
      @page = Page.build :title => nil
      @page.valid?
      @page.errors.on(:title).should_not == nil
    end
    
    it "should require a description" do
      @page = Page.build :description => nil
      @page.valid?
      @page.errors.on(:description).should_not == nil
    end
    
    it "should require content" do
      @page = Page.build(:content => nil)
      @page.valid?
      @page.errors.on(:content).should_not == nil
    end
    
    it "should set the display_order" do
      @page = Page.build!
      @page.display_order.should_not == nil
    end
    
    it "should start without any roles" do
      @page = Page.build!
      @page.roles.should == []
    end
    
    it "should start in the pending_review state" do
      @page = Page.build!
      @page.current_state.should == :pending_review
    end
  end
  
  describe "being deleted" do
    before(:each) do
      @page = pages(:child)
      @page.delete!
    end
    
    it "should return nil for display_order" do
      @page.display_order.should == nil
    end
    
    it "should return 0 for max_display_order if no siblings" do
      Page.max_display_order(@page).should == 0
    end
  end
end
