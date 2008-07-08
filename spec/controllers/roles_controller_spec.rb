require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RolesController do
  fixtures :users, :roles
  
  describe "handling GET /roles" do

    before(:each) do
      login_as :admin
      @object = mock_model(Role)
      Role.stub!(:find).and_return([@object])
    end
  
    def do_get
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render index template" do
      do_get
      response.should render_template('index')
    end
  
    it "should find all roles" do
      Role.should_receive(:find).with(:all).and_return([@object])
      do_get
    end
  
    it "should assign the found roles for the view" do
      do_get
      assigns(:objects).should == [@object]
    end
  end

  describe "handling GET /roles.xml" do

    before(:each) do
      login_as :admin
      @objects = mock("Array of Roles", :to_xml => "XML")
      Role.stub!(:find).and_return(@objects)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all roles" do
      Role.should_receive(:find).with(:all).and_return(@objects)
      do_get
    end
  
    it "should render the found roles as xml" do
      @objects.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /roles/:id" do

    before(:each) do
      login_as :admin
      @id = users(:admin).id
      @object = mock_model(Role)
      Role.stub!(:find_by_id).and_return(@object)
    end
  
    def do_get
      get :show, :id => @id
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render show template" do
      do_get
      response.should render_template('show')
    end
  
    it "should find the role requested" do
      Role.should_receive(:find_by_id).with(@id).and_return(@object)
      do_get
    end
  
    it "should assign the found role for the view" do
      do_get
      assigns(:object).should equal(@object)
    end
  end

  describe "handling GET /roles/:id.xml" do

    before(:each) do
      login_as :admin
      @id = users(:admin).id
      @object = mock_model(Role, :to_xml => "XML")
      Role.stub!(:find_by_id).and_return(@object)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => @id
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the role requested" do
      Role.should_receive(:find_by_id).with(@id).and_return(@object)
      do_get
    end
  
    it "should render the found role as xml" do
      @object.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /roles/new" do

    before(:each) do
      login_as :admin
      @object = mock_model(Role)
      Role.stub!(:new).and_return(@object)
    end
  
    def do_get
      get :new
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render new template" do
      do_get
      response.should render_template('form')
    end
  
    it "should create an new role" do
      Role.should_receive(:new).and_return(@object)
      do_get
    end
  
    it "should not save the new role" do
      @object.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new role for the view" do
      do_get
      assigns(:object).should equal(@object)
    end
  end

  describe "handling GET /roles/:id/edit" do

    before(:each) do
      login_as :admin
      @id = users(:admin).id
      @object = mock_model(Role)
      Role.stub!(:find_by_id).and_return(@object)
    end
  
    def do_get
      get :edit, :id => @id
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render edit template" do
      do_get
      response.should render_template('form')
    end
  
    it "should find the role requested" do
      Role.should_receive(:find_by_id).and_return(@object)
      do_get
    end
  
    it "should assign the found Role for the view" do
      do_get
      assigns(:object).should equal(@object)
    end
  end

  describe "handling POST /roles" do

    before(:each) do
      login_as :admin
      @id = users(:admin).id
      @object = mock_model(Role, :to_param => @id)
      Role.stub!(:new).and_return(@object)
    end
    
    describe "with successful save" do
  
      def do_post
        @object.should_receive(:save!).and_return(true)
        @controller.should_receive(:create_change_log_entry)
        post :create, :role => {}
      end
  
      it "should create a new role" do
        Role.should_receive(:new).with({}).and_return(@object)
        do_post
      end

      it "should redirect to the new role" do
        do_post
        response.should redirect_to(role_url(@id))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @object.errors.stub!(:full_messages).and_return([])
        @object.should_receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(@object))
        @controller.should_not_receive(:create_change_log_entry)
        post :create, :role => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('form')
      end
      
    end
  end

  describe "handling PUT /roles/:id" do

    before(:each) do
      login_as :admin
      @id = users(:admin).id
      @object = mock_model(Role, :to_param => @id)
      Role.stub!(:find_by_id).and_return(@object)
    end
    
    describe "with successful update" do

      def do_put
        @object.should_receive(:update_attributes!).and_return(true)
        @controller.should_receive(:create_change_log_entry)
        put :update, :id => @id
      end

      it "should find the role requested" do
        Role.should_receive(:find_by_id).with(@id).and_return(@object)
        do_put
      end

      it "should update the found role" do
        do_put
        assigns(:object).should equal(@object)
      end

      it "should assign the found role for the view" do
        do_put
        assigns(:object).should equal(@object)
      end

      it "should redirect to the role" do
        do_put
        response.should redirect_to(role_url(@id))
      end

    end
    
    describe "with failed update" do

      def do_put
        @object.errors.stub!(:full_messages).and_return([])
        @object.should_receive(:update_attributes!).and_raise(ActiveRecord::RecordInvalid.new(@object))
        @controller.should_not_receive(:create_change_log_entry)
        put :update, :id => @id
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('form')
      end
      
    end
  end
  
  describe "handling DELETE /roles/:id" do
    
    before(:each) do
      login_as :admin
      @id = 100
      @object = mock_model(Role, :to_param => @id, :destroy => true)
      @object.stub!(:title).and_return('not administrator role')
      Role.stub!(:find_by_id).and_return(@object)
    end
  
    def do_delete
      delete :destroy, :id => @id
    end

    it "should find the role, destroy, and redirect to the index" do
      Role.should_receive(:find_by_id).with(@id).and_return(@object)
      @controller.should_receive(:create_change_log_entry)
      @object.should_receive(:title).and_return('not administrator role')
      @object.should_receive(:destroy)
      do_delete
      response.should redirect_to(roles_path)
    end
  
    describe "of the administrator role" do
      it "should fail" do
        @controller.should_not_receive(:create_change_log_entry)
        @admin_role = roles(:administrator)
        Role.stub!(:find_by_id).and_return(@admin_role)
        delete :destroy, :id => @admin_role.id
        flash[:error].should_not == nil
      end
    end
  end
end
