require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PagesController do
  fixtures :users, :roles, :pages
  
  describe "handling GET /home" do
    describe "when published" do
      before(:each) do
        @object = Page.build!
        @object.stub!(:is_home_page).and_return(true)
      end
      
      describe "as an administrator" do
        before(:each) do
          login_as :admin
        end
        
        def do_get
          Page.should_receive(:find_by_is_home_page).with(true).at_least(:once).and_return(@object)
          get :home
        end
        
        it "should return the site index" do
          do_get
          response.should render_template('show')
          response.should be_success
        end
      end
      
      describe "while not logged in" do
        def do_get
          Page.should_receive(:find_in_state).with(:first, :published, :conditions => {:is_home_page => true}).at_least(:once).and_return(@object)
          get :home
        end
        
        it "should return the site index" do
          do_get
          response.should render_template('show')
          response.should be_success
        end
      end
    end
    
    describe "when unpublished" do
      before(:each) do
        @object = Page.build! :aasm_state => 'unpublished'
        @object.stub!(:is_home_page).and_return(true)
      end
      
      describe "as an administrator" do
        before(:each) do
          login_as :admin
        end
        
        def do_get
          Page.should_receive(:find_by_is_home_page).with(true).at_least(:once).and_return(@object)
          get :home
        end
        
        it "should return the site index" do
          do_get
          response.should render_template('show')
          response.should be_success
        end
      end
      
      describe "while not logged in" do
        def do_get
          Page.should_receive(:find_in_state).with(:first, :published, :conditions => {:is_home_page => true}).at_least(:once).and_return(nil)
          get :home
        end
        
        it "should return the under_consruction template" do
          do_get
          response.response_code.should == 501
          response.should render_template('under_construction')
        end
      end
    end
  end
  
  describe "handling GET /admin" do
    before(:each) do
      @object = Page.build!
      @object.stub!(:is_admin_home_page).and_return(true)
    end
    
    def do_get
      get :admin
    end
    
    describe "when published" do
      before(:each) do
        @object.stub!(:current_state).and_return(:published)
      end
      
      describe "as an administrator" do
        before(:each) do
          login_as :admin
        end
        
        it "should return the admin dashboard" do
          do_get
          response.should render_template('admin')
          response.should be_success
        end
      end
      
      describe "as a normal user" do
        before(:each) do
          login_as :active_non_admin
        end
        
        it "should redirect because unauthorized" do
          do_get
          response.response_code.should == 302
          response.should redirect_to(root_path)
        end
      end
      
      describe "while not logged in" do
        it "should redirect to login" do
          do_get
          response.response_code.should == 302
          response.should redirect_to(login_path)
        end
      end
    end
    
    describe "when not published" do
      before(:each) do
        @object.stub!(:current_state).and_return(:unpublished)
      end
      
      it "should return the coming_soon template" do
        do_get
        response.response_code.should == 302
        response.should redirect_to(login_path)
      end
    end
  end
  
  describe "handling GET /pages" do
    def do_get
      get :index
    end

    before(:each) do
      login_as :admin
      @object = mock_model(Page)
      Page.stub!(:find).and_return([@object])
    end

    describe "as an administrator" do
      before(:each) do
        login_as :admin
      end

      it "should find all pages, and assign them for the index template" do
        Page.should_receive(:find).and_return([@object])
        do_get
        response.should be_success
        response.should render_template('index')
        assigns[:objects].should == [@object]
      end
    end
    
    describe "as a normal user" do
      before(:each) do
        login_as :active_non_admin
      end

      it "should fail" do
        Page.should_not_receive(:find).with(:all)
        do_get
        flash[:error].should_not == nil
        response.response_code.should == 302
      end
    end
  end

  describe "handling GET /pages.xml" do
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end

    before(:each) do
      @objects = mock("Array of Pages", :to_xml => "XML")
      Page.stub!(:find).and_return(@objects)
    end

    describe "as an administrator" do
      before(:each) do
        login_as :admin
      end

      it "should find all pages and render as XML" do
        Page.should_receive(:find).and_return(@objects)
        @objects.should_receive(:to_xml).and_return("XML")
        do_get
        response.should be_success
        response.body.should == "XML"
      end
    end
    
    describe "as a normal user" do
      before(:each) do
        login_as :active_non_admin
      end

      it "should fail" do
        Page.should_not_receive(:find).with(:all)
        do_get
        response.body.should == "You don't have permission to complete this action."
        response.response_code.should == 401
      end
    end
  end

  describe "handling GET /pages/:id" do
    def do_get
      get :show, :id => @object.id
    end

    describe "as an administrator" do
      before(:each) do
        login_as :admin
      end
      
      describe "on an unsecured page" do
        before(:each) do
          @object = pages(:unsecured)
          Page.stub!(:find_by_id).and_return(@object)
        end

        it "should find the page requested, and assign it for the show template" do
          Page.should_receive(:find_by_id).with(@object.id).at_least(:once).and_return(@object)
          do_get
          response.should be_success
          assigns(:object).should equal(@object)
          response.should render_template('show')
        end
      end
      
      describe "on an unpublished page" do
        before(:each) do
          @object = pages(:approved)
        end
        
        it "should render the 'preview' warning" do
          do_get
          response.should render_template('show')
          flash[:warning].should == 'This is a preview.  This page is not published.'
        end
      end
    end
    
    describe "as a user not logged in" do
      before(:each) do
        @object = pages(:unsecured)
      end

      it "should find the page requested, and assign it for the show template" do
        Page.should_receive(:find_in_state).with(:first, :published, :conditions => {:id => @object.id}).at_least(:once).and_return(@object)
        do_get
        response.should be_success
        assigns(:object).should equal(@object)
        response.should render_template('show')
      end
      
      describe "on an unpublished page" do
        before(:each) do
          @object = pages(:approved)
        end
        it "should render page not found" do
          do_get
          response.should render_template('pages/not_found')
        end
      end
    end
  end

  describe "handling GET /pages/:id.xml" do
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => @object.id
    end

    describe "as an administrator" do
      before(:each) do
        login_as :admin
      end

      describe "on an unsecured page" do
        before(:each) do
          @object = pages(:unsecured)
          Page.stub!(:find_by_id).and_return(@object)
        end

        it "should find the page requested and render as XML" do
          Page.should_receive(:find_by_id).with(@object.id).at_least(:once).and_return(@object)
          @object.should_receive(:to_xml).and_return("XML")
          do_get
          response.should be_success
          response.body.should == "XML"
        end
      end
      
      describe "on a secured page" do
        before(:each) do
          @object = pages(:secured)
          Page.stub!(:find_by_id).and_return(@object)
        end

        it "should find the page requested and render as XML" do
          Page.should_receive(:find_by_id).with(@object.id).at_least(:once).and_return(@object)
          @object.should_receive(:to_xml).and_return("XML")
          do_get
          response.body.should == "XML"
        end
      end
    end
    
    describe "while not logged in" do
      describe "on an unsecured page" do
        before(:each) do
          @object = pages(:unsecured)
          Page.stub!(:find_in_state).and_return(@object)
        end

        it "should find the page requested and render as XML" do
          Page.should_receive(:find_in_state).with(:first, :published, :conditions => {:id => @object.id}).at_least(:once).and_return(@object)
          @object.should_receive(:to_xml).and_return("XML")
          do_get
          response.should be_success
          response.body.should == "XML"
        end
      end
      
      describe "on a secured page" do
        before(:each) do
          @object = pages(:secured)
          Page.stub!(:find_in_state).and_return(@object)
        end

        it "should give persmission denied" do
          Page.should_receive(:find_in_state).with(:first, :published, :conditions => {:id => @object.id}).at_least(:once).and_return(@object)
          do_get
          response.body.should == "You don't have permission to complete this action."
        end
      end
    end
  end

  describe "handling GET /show/:title" do
    def do_get
      get :show_by_title, :title => @object.title.gsub(/ /, '_')
    end

    describe "as an administrator" do
      before(:each) do
        login_as :admin
      end
      
      describe "on an unsecured page" do
        before(:each) do
          @object = pages(:unsecured)
          Page.should_receive(:find_by_title).with(@object.title).at_least(:once).and_return(@object)
        end

        it "should find the page requested, and assign it for the show template" do
          do_get
          response.should be_success
          assigns(:object).should equal(@object)
          response.should render_template('show')
        end
      end
    end
    
    describe "as a user not logged in" do
      before(:each) do
        @object = pages(:unsecured)
      end

      it "should find the page requested, and assign it for the show template" do
        Page.should_receive(:find_in_state).with(:first, :published, :conditions => {:title => @object.title}).at_least(:once).and_return(@object)
        do_get
        response.should be_success
        assigns(:object).should equal(@object)
        response.should render_template('show')
      end
      
      describe "on an unpublished page" do
        before(:each) do
          @object = pages(:approved)
        end
        
        it "should render the not_found template" do
          Page.should_receive(:find_in_state).with(:first, :published, :conditions => {:title => @object.title}).at_least(:once).and_return(nil)
          do_get
          response.should render_template('not_found')
        end
      end
      
      describe "on a page with an advanced_path" do
        before(:each) do
          @object = pages(:advanced_path)
        end
        
        it "should redirect the user to the advanced_path" do
          @controller.should_receive(:redirect_to).with('/')
          do_get
          response.should be_success
          response.should render_template('pages/show_by_title')
        end
      end
    end
  end

  describe "handling GET /pages/new" do
    before(:each) do
      @object = mock_model(Page)
      Page.stub!(:new).and_return(@object)
    end

    def do_get
      get :new
    end

    describe "as an administrator" do
      before(:each) do
        login_as :admin
      end

      it "should create a new page and render the new template" do
        Page.should_receive(:new).and_return(@object)
        @object.should_not_receive(:save)
        do_get
        response.should be_success
        assigns(:object).should equal(@object)
        response.should render_template('form')
      end
    end
    
    describe "as a normal user" do
      before(:each) do
        login_as :active_non_admin
      end

      it "should fail" do
        Page.should_not_receive(:find_by_id)
        @object.should_not_receive(:new)
        do_get
        flash[:error].should_not == nil
        response.response_code.should == 302
      end
    end
  end

  describe "handling GET /pages/:id/edit" do
    before(:each) do
      @object = mock_model(Page)
      Page.stub!(:find_by_id).and_return(@object)
    end

    def do_get
      get :edit, :id => @object.id
    end

    describe "as an administrator" do
      before(:each) do
        login_as :admin
      end

      it "should find the page requested, and render the edit form" do
        Page.should_receive(:find_by_id).at_least(:once).and_return(@object)
        do_get
        response.should be_success
        assigns(:object).should equal(@object)
        response.should render_template('form')
      end
    end
    
    describe "as a normal user" do
      before(:each) do
        login_as :active_non_admin
      end

      it "should fail" do
        Page.should_not_receive(:find_by_id)
        @object.should_not_receive(:new)
        do_get
        flash[:error].should_not == nil
        response.response_code.should == 302
      end
    end
  end

  describe "handling POST /pages" do
    before(:each) do
      @object = mock_model(Page)
      Page.stub!(:new).and_return(@object)
    end

    describe "as an administrator" do
      before(:each) do
        login_as :admin
      end

      describe "with successful save" do
        def do_post
          @object.should_receive(:save!).and_return(true)
          post :create, :page => {}
        end

        it "should create a new page, and redirect to it" do
          Page.should_receive(:new).with({}).and_return(@object)
          do_post
          assigns(:object).should == @object
          response.should redirect_to(page_url(@object.id))
        end
      end

      describe "with failed save" do
        def do_post
          @object.errors.stub!(:full_messages).and_return([])
          @object.should_receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(@object))
          post :create, :page => {}
        end

        it "should re-render 'new'" do
          do_post
          response.should render_template('form')
        end
      end
    end
    
    describe "as a normal user" do
      before(:each) do
        login_as :active_non_admin
      end

      def do_post
        post :create, :page => {}
      end

      it "should fail" do
        Page.should_not_receive(:find_by_id)
        @object.should_not_receive(:new)
        do_post
        flash[:error].should_not == nil
        response.response_code.should == 302
      end
    end
  end

  describe "handling PUT /pages/:id" do
    describe "as an administrator" do
      before(:each) do
        login_as :admin
        @object = mock_model(Page)
        Page.stub!(:find_by_id).and_return(@object)
      end

      describe "with successful update" do
        def do_put
          @controller.should_receive(:create_change_log_entry)
          @object.should_receive(:update_attributes).and_return(true)
          @object.should_receive(:advanced_path).and_return(nil)
          put :update, :id => @object.id
        end

        it "should update the found page, and redirect to it" do
          Page.should_receive(:find_by_id).with(@object.id).at_least(:once).and_return(@object)
          do_put
          assigns(:object).should == @object
          response.should redirect_to(page_url(@object.id))
        end
      end

      describe "with failed update" do
        def do_put
          @object.errors.stub!(:full_messages).and_return([])
          @object.should_receive(:update_attributes).and_raise(ActiveRecord::RecordInvalid.new(@object))
          put :update, :id => @object.id
        end

        it "should re-render 'edit'" do
          do_put
          response.should render_template('form')
        end
      end
    end
    
    describe "as a normal user" do
      before(:each) do
        login_as :active_non_admin
        @object = pages(:unsecured)
      end
      
      def do_put
        put :update, :id => @object.id
      end

      it "should fail" do
        Page.should_not_receive(:find_by_id)
        @object.should_not_receive(:update_attributes)
        do_put
        flash[:error].should_not == nil
        response.response_code.should == 302
      end
    end
  end

  describe "handling DELETE /pages/:id" do
    describe "as an administrator" do
      before(:each) do
        login_as :admin
        @admin = users(:admin)
        @object = pages(:unsecured)
      end

      def do_delete
        @controller.should_receive(:create_change_log_entry)
        delete :destroy, :id => @object.id
      end

      it "should find the page requested, delete it, and redirect to the pages list" do
        Page.should_receive(:find_by_id).with(@object.id).at_least(:once).and_return(@object)
        @object.should_not_receive(:destroy)
        @object.should_receive(:delete!)
        do_delete
        response.should redirect_to(pages_url)
      end
    end
    
    describe "as a normal user" do
      before(:each) do
        login_as :active_non_admin
        @object = pages(:unsecured)
      end
      
      def do_delete
        delete :destroy, :id => @object.id
      end
      
      it "should redirect and give permission denied" do
        do_delete
        flash[:error].should_not == nil
        response.response_code.should == 302
      end
    end
  end

  describe "handling DELETE /pages/purge/:id" do
    describe "as an administrator" do
      before(:each) do
        login_as :admin
      end

      describe "on a page in the :deleted state" do
        before(:each) do
          @object = pages(:deleted)
        end

        def do_delete
          Page.should_receive(:find_by_id).with(@object.id).at_least(:once).and_return(@object)
          @controller.should_receive(:create_change_log_entry)
          @object.should_receive(:destroy)
          delete :purge, :id => @object.id
        end

        it "should destroy the found page, and redirect to the index" do
          do_delete
          response.response_code.should == 302
          response.should redirect_to(pages_url)
          flash[:notice].should   == nil
          flash[:warning].should  == nil
          flash[:error].should    == nil
        end
      end

      describe "on a page not in the deleted state" do
        before(:each) do
          @object = pages(:unsecured)
        end

        def do_delete
          Page.should_receive(:find_by_id).with(@object.id).at_least(:once).and_return(@object)
          @object.should_not_receive(:destroy)
          delete :purge, :id => @object.id
        end

        it "should fail" do
          do_delete
          flash[:error].should_not == nil
        end
      end
    end
    
    describe "as a normal user" do
      before(:each) do
        login_as :active_non_admin
        @object = pages(:deleted)
      end
      
      def do_delete
        Page.should_not_receive(:find_by_id).with(@object.id)
        @object.should_not_receive(:destroy)
        delete :purge, :id => @object.id
      end

      it "should fail" do
        do_delete
        flash[:error].should_not == nil
        response.response_code.should == 302
        response.should redirect_to(root_path)
      end
    end
  end
  
  describe "handling PUT /pages/undelete/:id" do
    describe "as an administrator" do
      before(:each) do
        login_as :admin
      end

      describe "on a page in the :deleted state" do
        before(:each) do
          @object = pages(:deleted)
        end

        def do_put
          @controller.should_receive(:create_change_log_entry)
          put :undelete, :id => @object.id
        end

        it "should undelete the found page, and redirect to the index" do
          Page.should_receive(:find_by_id).with(@object.id).at_least(:once).and_return(@object)
          @object.should_receive(:undelete!)
          do_put
          response.response_code.should == 302
          response.should redirect_to(pages_url)
          flash[:notice].should   == nil
          flash[:warning].should  == nil
          flash[:error].should    == nil
        end
        
        it "should put the page into the :pending_review state" do
          do_put
          assigns(:object).current_state.should == :pending_review
        end
      end

      describe "on a page not in the deleted state" do
        before(:each) do
          @object = pages(:unsecured)
        end

        def do_put
          delete :undelete, :id => @object.id
        end

        it "should fail and redirect to the pages index" do
          Page.should_receive(:find_by_id).with(@object.id).at_least(:once).and_return(@object)
          @object.should_not_receive(:undelete!)
          do_put
          flash[:error].should_not == nil
          response.should redirect_to(pages_url)
        end
        
        it "should not put the page into the :pending_review state" do
          do_put
          assigns(:object).current_state.should_not == :pending_review
        end
      end
    end
    
    describe "as a normal user" do
      before(:each) do
        login_as :active_non_admin
        @object = pages(:deleted)
      end
      
      def do_put
        put :undelete, :id => @object.id
      end

      it "should fail and redirect to the root path" do
        Page.should_not_receive(:find_by_id).with(@object.id)
        @object.should_not_receive(:undelete!)
        do_put
        flash[:error].should_not == nil
        response.response_code.should == 302
        response.should redirect_to(root_path)
      end
    end
  end

  describe "handling PUT /pages/publish/:id" do
    describe "as an administrator" do
      before(:each) do
        login_as :admin
      end

      describe "on a page in the :approved state" do
        before(:each) do
          @object = pages(:approved)
        end

        def do_put
          @controller.should_receive(:create_change_log_entry)
          put :publish, :id => @object.id
        end

        it "should publish the found page, and redirect to the index" do
          Page.should_receive(:find_by_id).with(@object.id).at_least(:once).and_return(@object)
          @object.should_receive(:publish!)
          do_put
          response.response_code.should == 302
          response.should redirect_to(pages_url)
          flash[:notice].should   == nil
          flash[:warning].should  == nil
          flash[:error].should    == nil
        end
        
        it "should put the page into the :published state" do
          do_put
          assigns(:object).current_state.should == :published
        end
      end

      describe "on a page not in the approved state" do
        before(:each) do
          @object = pages(:deleted)
        end

        def do_put
          delete :publish, :id => @object.id
        end

        it "should fail and redirect to the pages index" do
          Page.should_receive(:find_by_id).with(@object.id).at_least(:once).and_return(@object)
          @object.should_not_receive(:publish!)
          do_put
          flash[:error].should_not == nil
          response.should redirect_to(pages_url)
        end
        
        it "should not put the page into the :published state" do
          do_put
          assigns(:object).current_state.should_not == :published
        end
      end
    end
    
    describe "as a normal user" do
      before(:each) do
        login_as :active_non_admin
        @object = pages(:approved)
      end
      
      def do_put
        put :publish, :id => @object.id
      end

      it "should fail and redirect to the root path" do
        Page.should_not_receive(:find_by_id).with(@object.id)
        @object.should_not_receive(:publish!)
        do_put
        flash[:error].should_not == nil
        response.response_code.should == 302
        response.should redirect_to(root_path)
      end
    end
  end

  describe "handling PUT /pages/unpublish/:id" do
    describe "as an administrator" do
      before(:each) do
        login_as :admin
      end

      describe "on a page in the :published state" do
        before(:each) do
          @object = pages(:unsecured)
        end

        def do_put
          @controller.should_receive(:create_change_log_entry)
          put :unpublish, :id => @object.id
        end

        it "should unpublish the found page, and redirect to the index" do
          Page.should_receive(:find_by_id).with(@object.id).at_least(:once).and_return(@object)
          @object.should_receive(:unpublish!)
          do_put
          response.response_code.should == 302
          response.should redirect_to(pages_url)
          flash[:notice].should   == nil
          flash[:warning].should  == nil
          flash[:error].should    == nil
        end
        
        it "should put the page into the :unpublished state" do
          do_put
          assigns(:object).current_state.should == :unpublished
        end
      end

      describe "on a page not in the :published state" do
        before(:each) do
          @object = pages(:deleted)
        end

        def do_put
          delete :unpublish, :id => @object.id
        end

        it "should fail and redirect to the pages index" do
          Page.should_receive(:find_by_id).with(@object.id).at_least(:once).and_return(@object)
          @object.should_not_receive(:unpublish!)
          do_put
          flash[:error].should_not == nil
          response.should redirect_to(pages_url)
        end
        
        it "should not put the page into the :unpublished state" do
          do_put
          assigns(:object).current_state.should_not == :unpublished
        end
      end
    end
    
    describe "as a normal user" do
      before(:each) do
        login_as :active_non_admin
        @object = pages(:unsecured)
      end
      
      def do_put
        put :unpublish, :id => @object.id
      end

      it "should fail and redirect to the root path" do
        Page.should_not_receive(:find_by_id).with(@object.id)
        @object.should_not_receive(:unpublish!)
        do_put
        flash[:error].should_not == nil
        response.response_code.should == 302
        response.should redirect_to(root_path)
      end
    end
  end

  describe "handling PUT /pages/approve/:id" do
    describe "as an administrator" do
      before(:each) do
        login_as :admin
      end

      describe "on a page in the :pending_review state" do
        before(:each) do
          @object = pages(:pending_review)
        end

        def do_put
          @controller.should_receive(:create_change_log_entry)
          put :approve, :id => @object.id
        end

        it "should approve the found page, and redirect to the index" do
          Page.should_receive(:find_by_id).with(@object.id).at_least(:once).and_return(@object)
          @object.should_receive(:approve!)
          do_put
          response.response_code.should == 302
          response.should redirect_to(pages_url)
          flash[:notice].should   == nil
          flash[:warning].should  == nil
          flash[:error].should    == nil
        end
        
        it "should put the page into the :approved state" do
          do_put
          assigns(:object).current_state.should == :approved
        end
      end

      describe "on a page not in the :pending_review state" do
        before(:each) do
          @object = pages(:deleted)
        end

        def do_put
          delete :approve, :id => @object.id
        end

        it "should fail and redirect to the pages index" do
          Page.should_receive(:find_by_id).with(@object.id).at_least(:once).and_return(@object)
          @object.should_not_receive(:approve!)
          do_put
          flash[:error].should_not == nil
          response.should redirect_to(pages_url)
        end
        
        it "should not put the page into the :approved state" do
          do_put
          assigns(:object).current_state.should_not == :approved
        end
      end
    end
    
    describe "as a normal user" do
      before(:each) do
        login_as :active_non_admin
        @object = pages(:pending_review)
      end
      
      def do_put
        put :approve, :id => @object.id
      end

      it "should fail and redirect to the root path" do
        Page.should_not_receive(:find_by_id).with(@object.id)
        @object.should_not_receive(:approve!)
        do_put
        flash[:error].should_not == nil
        response.response_code.should == 302
        response.should redirect_to(root_path)
      end
    end
  end
  
  describe "handling PUT /pages/:id/set_display_order/:display_order" do
    def do_put
      put :set_display_order, :id => @object.id, :display_order => @object.display_order + @increment
    end
    
    describe "to the same value" do
      before(:each) do
        @object = pages(:secured)
        @increment = 0
        login_as :admin
      end
      
      it "should warn no change made and redirect to the pages url" do
        Page.should_receive(:find_by_id).with(@object.id).at_least(:once).and_return(@object)
        @object.should_not_receive(:display_order=)
        @object.should_not_receive(:save)
        do_put
        response.response_code.should == 302
        response.should redirect_to(pages_url)
        flash[:notice].should       == nil
        flash[:warning].should_not  == nil
        flash[:error].should        == nil
      end
      
      it "should not change the display_order" do
        do_put
        assigns(:object).display_order.should == @object.display_order
      end
    end
    
    describe "to a higher order" do
      before(:each) do
        @object = pages(:secured)
        @increment = 2
      end
      
      describe "as an administrator" do
        before(:each) do
          login_as :admin
        end
        
        it "should reorder the pages and redirect to the page index" do
          Page.should_receive(:find_by_id).with(@object.id).at_least(:once).and_return(@object)
          @object.should_receive(:display_order=)
          @object.should_receive(:save).with(false)
          do_put
          response.response_code.should == 302
          response.should redirect_to(pages_url)
          flash[:notice].should   == nil
          flash[:warning].should  == nil
          flash[:error].should    == nil
        end
        
        it "should increment the display_order by 2" do
          do_put
          assigns(:object).display_order.should == @object.display_order + @increment
        end
      end
      
      describe "as a normal user" do
        before(:each) do
          login_as :active_non_admin
        end
        
        it "should fail and redirect to the root path" do
          Page.should_not_receive(:find_by_id).with(@object.id)
          @object.should_not_receive(:display_order=)
          @object.should_not_receive(:save)
          do_put
          flash[:error].should_not == nil
          response.response_code.should == 302
          response.should redirect_to(root_path)
        end
      end
    end
    
    describe "to a lower order" do
      before(:each) do
        @object = pages(:pending_review)
        @increment = -2
      end
      
      describe "as an administrator" do
        before(:each) do
          login_as :admin
        end
        
        it "should reorder the pages and redirect to the page index" do
          Page.should_receive(:find_by_id).with(@object.id).at_least(:once).and_return(@object)
          @object.should_receive(:display_order=)
          @object.should_receive(:save).with(false)
          do_put
          response.response_code.should == 302
          response.should redirect_to(pages_url)
          flash[:notice].should   == nil
          flash[:warning].should  == nil
          flash[:error].should    == nil
        end
        
        it "should decrement the display_order by 2" do
          do_put
          assigns(:object).display_order.should == @object.display_order + @increment
        end
      end
      
      describe "as a normal user" do
        before(:each) do
          login_as :active_non_admin
        end
        
        it "should fail and redirect to the root path" do
          Page.should_not_receive(:find_by_id).with(@object.id)
          @object.should_not_receive(:display_order=)
          @object.should_not_receive(:save)
          do_put
          flash[:error].should_not == nil
          response.response_code.should == 302
          response.should redirect_to(root_path)
        end
      end
    end
  end

  describe "handling PUT /pages/:id/set_parent/:parent_id" do
    def do_put
      put :set_parent, :id => @object.id, :parent_id => @parent_id
    end
    
    describe "to the same parent_id" do
      before(:each) do
        login_as :admin
        @object = pages(:secured)
        @parent_id = @object.parent_id
      end
      
      it "should warn no change made and redirect to the pages url" do
        Page.should_receive(:find_by_id).with(@object.id).at_least(:once).and_return(@object)
        @controller.should_not_receive(:create_change_log_entry)
        @object.should_not_receive(:parent=)
        @object.should_not_receive(:save)
        do_put
        response.response_code.should == 302
        response.should redirect_to(pages_url)
        flash[:notice].should       == nil
        flash[:warning].should_not  == nil
        flash[:error].should        == nil
      end
      
      it "should not change the parent_id" do
        do_put
        assigns(:object).parent_id.should == @object.parent_id
      end
    end
    
    describe "to a sibling's id" do
      before(:each) do
        @object = pages(:unsecured)
        @parent = pages(:secured)
        @parent_id = @parent.id
      end
      
      describe "as an administrator" do
        before(:each) do
          login_as :admin
        end
        
        it "should change the parent_id and redirect to the page index" do
          Page.should_receive(:find_by_id).with(@object.id).at_least(:once).and_return(@object)
          Page.should_receive(:find_by_id).with(@parent_id).at_least(:once).and_return(@parent)
          @controller.should_receive(:create_change_log_entry)
          @object.should_receive(:parent=)
          @object.should_receive(:save).with(false)
          do_put
          response.response_code.should == 302
          response.should redirect_to(pages_url)
          flash[:notice].should   == nil
          flash[:warning].should  == nil
          flash[:error].should    == nil
        end
        
        it "should increment the display_order by 2" do
          @controller.should_receive(:create_change_log_entry)
          do_put
          assigns(:object).parent_id.should == @parent_id
        end
      end
      
      describe "as a normal user" do
        before(:each) do
          login_as :active_non_admin
        end
        
        it "should fail and redirect to the root path" do
          Page.should_not_receive(:find_by_id).with(@object.id)
          Page.should_not_receive(:find_by_id).with(@parent_id)
          @controller.should_not_receive(:create_change_log_entry)
          @object.should_not_receive(:parent=)
          @object.should_not_receive(:save)
          do_put
          flash[:error].should_not == nil
          response.response_code.should == 302
          response.should redirect_to(root_path)
        end
      end
    end
    
    describe "to the parent's parent" do
      before(:each) do
        @object = pages(:child)
        @parent_id = @object.parent.parent_id
      end
      
      describe "as an administrator" do
        before(:each) do
          login_as :admin
        end
        
        it "should change the parent and redirect to the page index" do
          Page.should_receive(:find_by_id).with(@object.id).at_least(:once).and_return(@object)
          Page.should_not_receive(:find_by_id).with(@parent_id)   # because it's nil
          @controller.should_receive(:create_change_log_entry)
          @object.should_receive(:parent=)
          @object.should_receive(:save).with(false)
          do_put
          response.response_code.should == 302
          response.should redirect_to(pages_url)
          flash[:notice].should   == nil
          flash[:warning].should  == nil
          flash[:error].should    == nil
        end
        
        it "should change the parent" do
          @controller.should_receive(:create_change_log_entry)
          do_put
          assigns(:object).parent_id.should == @parent_id
        end
      end
      
      describe "as a normal user" do
        before(:each) do
          login_as :active_non_admin
        end
        
        it "should fail and redirect to the root path" do
          Page.should_not_receive(:find_by_id).with(@object.id)
          @controller.should_not_receive(:create_change_log_entry)
          @object.should_not_receive(:display_order=)
          @object.should_not_receive(:save)
          do_put
          flash[:error].should_not == nil
          response.response_code.should == 302
          response.should redirect_to(root_path)
        end
      end
    end
  end
  
  describe "creating change_log entries" do
    before(:each) do
      login_as :admin
      @admin = users(:admin)
      @object = pages(:secured)
    end
    
    def do_delete
      ChangeLog.should_receive(:new).and_return(@change_log)
      delete :destroy, :id => @object.id
    end
    
    it "should require comments if destroying or purging" do
      @change_log = ChangeLog.build(:object_class => @object.class.name.downcase, :object_id => @object.id, :action => 'destroy', :comments => nil)
      @change_log.should_receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(@change_log))
      do_delete
      response.should render_template('shared/get_comments')
      @change_log.valid?
      @change_log.errors.on(:comments).should_not == nil
    end
    
    it "should up the change_log count" do
      @comments = "Testing destroy with comments."
      @change_log = ChangeLog.build(:object_class => @object.class.name.downcase, :object_id => @object.id, :action => 'destroy', :comments => @comments)
      lambda {
        do_delete
      }.should change(ChangeLog, :count).by(1)
      response.should redirect_to(pages_url)
    end
  end
  
  describe "handling GET /sitemap" do
    before(:each) do
      @objects = [pages(:home), pages(:secured), pages(:child), pages(:unsecured)]
    end
    
    def do_get
      get :sitemap
    end
    
    it "should successfully return published unsecured pages" do
      Page.should_receive(:find_in_state).with(:all, :published, :conditions => {:parent_id => nil}, :order => 'is_home_page DESC, is_admin_home_page, display_order').and_return(@objects)
      @objects.should_receive(:reject)
      do_get
      response.should be_success
    end
  end
end
