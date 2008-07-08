require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/pages/index.html.erb" do
  include PagesHelper
  
  before(:each) do
    author = mock_model(User)
    author.stub!(:name).and_return("Author")
    
    page_96 = mock_model(Page)
    page_96.should_receive(:parent_id).at_least(:once)
    page_96.should_receive(:siblings).at_least(:once).and_return([])
    page_96.should_receive(:title).at_least(:once).and_return("Title")
    page_96.should_receive(:description).and_return("description")
    #page_96.should_receive(:display_order).at_least(:once).and_return(2)
    #page_96.should_receive(:author).and_return(author)
    page_96.should_receive(:is_home_page?).at_least(:once).and_return(false)
    page_96.should_receive(:is_admin_home_page?).at_least(:once).and_return(false)
    #page_96.should_receive(:is_important?).at_least(:once).and_return(false)
    page_96.should_receive(:current_state).at_least(:once).and_return(:deleted)
    #page_96.should_receive(:aasm_state).at_least(:once).and_return("pending_review")
    page_96.should_receive(:is_min_display_order?).at_least(:once).and_return(false)
    page_96.should_receive(:is_max_display_order?).at_least(:once).and_return(true)
    page_96.should_receive(:advanced_path).at_least(:once).and_return(nil)
    page_96.should_receive(:child_count).at_least(:once).and_return(0)
    
    page_97 = mock_model(Page)
    page_97.should_receive(:parent_id).at_least(:once)
    page_97.should_receive(:siblings).at_least(:once).and_return([])
    page_97.should_receive(:title).at_least(:once).and_return("Title")
    page_97.should_receive(:description).and_return("description")
    page_97.should_receive(:display_order).at_least(:once).and_return(1)
    #page_97.should_receive(:author).and_return(author)
    page_97.should_receive(:is_home_page?).at_least(:once).and_return(false)
    page_97.should_receive(:is_admin_home_page?).at_least(:once).and_return(false)
    page_97.should_receive(:is_important?).at_least(:once).and_return(false)
    page_97.should_receive(:current_state).at_least(:once).and_return(:approved)
    #page_97.should_receive(:aasm_state).at_least(:once).and_return("pending_review")
    page_97.should_receive(:is_min_display_order?).at_least(:once).and_return(false)
    page_97.should_receive(:is_max_display_order?).at_least(:once).and_return(true)
    page_97.should_receive(:advanced_path).at_least(:once).and_return(nil)
    page_97.should_receive(:child_count).at_least(:once).and_return(0)
    
    page_98 = mock_model(Page)
    page_98.should_receive(:parent_id).at_least(:once)
    page_98.should_receive(:siblings).at_least(:once).and_return([])
    page_98.should_receive(:title).at_least(:once).and_return("Title")
    page_98.should_receive(:description).and_return("description")
    page_98.should_receive(:display_order).at_least(:once).and_return(2)
    #page_98.should_receive(:author).and_return(author)
    page_98.should_receive(:is_home_page?).at_least(:once).and_return(false)
    page_98.should_receive(:is_admin_home_page?).at_least(:once).and_return(false)
    page_98.should_receive(:is_important?).at_least(:once).and_return(false)
    page_98.should_receive(:current_state).at_least(:once).and_return(:published)
    #page_98.should_receive(:aasm_state).at_least(:once).and_return("published")
    page_98.should_receive(:is_min_display_order?).at_least(:once).and_return(true)
    page_98.should_receive(:is_max_display_order?).at_least(:once).and_return(false)
    page_98.should_receive(:advanced_path).at_least(:once).and_return(nil)
    page_98.should_receive(:child_count).at_least(:once).and_return(0)

    page_99 = mock_model(Page)
    page_99.should_receive(:parent_id).at_least(:once)
    page_99.should_receive(:siblings).at_least(:once).and_return([])
    page_99.should_receive(:title).at_least(:once).and_return("Title")
    page_99.should_receive(:description).and_return("description")
    page_99.should_receive(:display_order).at_least(:once).and_return(3)
    #page_99.should_receive(:author).and_return(author)
    page_99.should_receive(:is_home_page?).at_least(:once).and_return(false)
    page_99.should_receive(:is_admin_home_page?).at_least(:once).and_return(false)
    page_99.should_receive(:is_important?).at_least(:once).and_return(false)
    page_99.should_receive(:current_state).at_least(:once).and_return(:pending_review)
    #page_99.should_receive(:aasm_state).at_least(:once).and_return("pending_review")
    page_99.should_receive(:is_min_display_order?).at_least(:once).and_return(false)
    page_99.should_receive(:is_max_display_order?).at_least(:once).and_return(true)
    page_99.should_receive(:advanced_path).at_least(:once).and_return(nil)
    page_99.should_receive(:child_count).at_least(:once).and_return(0)

    assigns[:objects] = [page_96, page_97, page_98, page_99]
  end

  it "should render list of pages" do
    render "/pages/index.html.erb"
    response.should have_tag("a[title=description]", "Title", 2)
    response.should have_tag("div>div>a>img[title=Edit]")
    response.should have_tag("div>div>a>img[title=Destroy]")
  end
end

