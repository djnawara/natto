require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ChangeLogsController do
  fixtures :users, :roles, :pages, :change_logs
  
  describe "handling GET /change_logs" do
    def do_get
      get :index
    end
    
    describe "as an administrator" do
      before(:each) do
        login_as :admin
      end
      
      describe "without params" do
        it "should return the complete change log listing" do
          do_get
          response.should render_template('index')
          response.should be_success
        end
      end
      
      describe "with object information in the params" do
        def do_get
          @objects = [change_logs(:suspended_user_suspend), change_logs(:suspended_user_activate)]
          @object = users(:suspended)
          ChangeLog.should_receive(:find).with(:all, 
                                                :conditions => {:object_class => @object.class.name.downcase, :object_id => @object.id.to_s},
                                                :order => 'performed_at DESC').and_return(@objects)
          get :index, :object_id => @object.id, :object_class => @object.class.name.downcase
        end
        
        it "should return the change log for the object" do
          do_get
          response.should render_template('index')
        end
      end
    end
    
    describe "while not logged in" do
      it "should redirect to login" do
        do_get
        response.should redirect_to(login_path)
      end
    end
  end
end
