require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationHelper do
  it "should provide icon images" do
    helper.tango('emotes/face-monkey.png', 'small image',  :small ).should have_tag('img[title="small image"]')
    helper.tango('emotes/face-monkey.png', 'medium image', :medium).should have_tag('img[title="medium image"]')
    helper.tango('emotes/face-monkey.png', 'large image',  :large ).should have_tag('img[title="large image"]')
    
    # Please improve this!
    helper.show_icon('show',            :large).should have_tag('img[title=show]')
    helper.purge_icon('purge',          :large).should have_tag('img[title=purge]')
    helper.users_icon('users',          :large).should have_tag('img[title=users]')
    helper.new_icon('new',              :large).should have_tag('img[title=new]')
    helper.roles_icon('roles',          :large).should have_tag('img[title=roles]')
    helper.login_icon('login',          :large).should have_tag('img[title=login]')
    helper.pages_icon('pages',          :large).should have_tag('img[title=pages]')
    helper.home_icon('home',            :large).should have_tag('img[title=home]')
    helper.account_icon('account',      :large).should have_tag('img[title=account]')
    helper.approve_icon('approve',      :large).should have_tag('img[title=approve]')
    helper.publish_icon('publish',      :large).should have_tag('img[title=publish]')
    helper.up_icon('up',                :large).should have_tag('img[title=up]')
    helper.back_icon('back',            :large).should have_tag('img[title=back]')
    helper.dashboard_icon('dashboard',  :large).should have_tag('img[title=dashboard]')
    helper.logout_icon('logout',        :large).should have_tag('img[title=logout]')
    helper.previous_icon('previous',    :large).should have_tag('img[title=previous]')
    helper.next_icon('next',            :large).should have_tag('img[title=next]')
    helper.redo_icon('redo',            :large).should have_tag('img[title=redo]')
    helper.save_icon('save',            :large).should have_tag('img[title=save]')
    helper.save_as_icon('save_as',      :large).should have_tag('img[title=save_as]')
  end
  
  it "should build our navigation menu" do
    role = mock_model(Role)
    role.stub!(:title).and_return('administrator')
    
    user = mock_model(User)
    user.stub!(:is_administrator).and_return(true)
    user.stub!(:roles).and_return([role])
    
    helper.stub!(:current_user).and_return(user)
    
    # FIXME
    #
    # BROKEN TEST NEEDS FIXING
    #helper.create_navigation.should have_tag("ul")
  end
end
