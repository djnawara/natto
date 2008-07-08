require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersController do
  fixtures :users, :roles, :change_logs
  
  describe "handling GET /users" do
    describe "as an administrator" do
      before(:each) do
        login_as :admin
        @object = mock_model(User)
        User.stub!(:find).and_return([@object])
      end

      it "should be successful" do
        get :index
        response.should be_success
      end

      it "should render index template" do
        get :index
        response.should render_template('index')
      end

      it "should find all users" do
        User.should_receive(:find).with(:all).and_return([@object])
        get :index
      end

      it "should assign the found users for the view" do
        get :index
        assigns(:objects).should == [@object]
      end
    end
    
    describe "as a normal user" do
      before(:each) do
        login_as :active_non_admin
      end

      it "should fail, and redirect to root" do
        User.should_not_receive(:find).with(:all)
        get :index
        flash[:error].should_not == nil # "You don't have permission to complete that action."
        response.should redirect_to(root_path)
      end
    end
    
    describe "while not logged in" do
      it "should fail, and redirect to login" do
        User.should_not_receive(:find).with(:all)
        get :index
        flash[:error].should_not == nil # "You are not authorized to view that resource."
        response.should redirect_to(login_path)
      end
    end
  end

  describe "handling GET /users.xml" do
    describe "as an administrator" do
      before(:each) do
        login_as :admin
        @objects = mock("Array of Users", :to_xml => "XML")
        User.stub!(:find).and_return(@objects)
      end

      def do_get
        @request.env["HTTP_ACCEPT"] = "application/xml"
        get :index
      end

      it "should find all users and render as XML" do
        User.should_receive(:find).with(:all).and_return(@objects)
        @objects.should_receive(:to_xml).and_return("XML")
        do_get
        response.should be_success
        response.body.should == "XML"
      end
    end
    
    describe "as a normal user" do
      describe "as an administrator" do
        before(:each) do
          login_as :active_non_admin
        end

        def do_get
          @request.env["HTTP_ACCEPT"] = "application/xml"
          get :index
        end

        it "should fail and render the error" do
          User.should_not_receive(:find).with(:all)
          do_get
          response.should_not be_success
          response.body.should == "You don't have permission to complete this action."
          response.response_code.should == 401
        end
      end
    end
    
    describe "while not logged in" do
      it "should fail, and redirect to login" do
        User.should_not_receive(:find).with(:all)
        get :index
        response.should_not be_success
        response.should redirect_to(login_path)
      end
    end
  end

  describe "handling GET /users/:id" do
    
    describe "as an administrator" do
      before(:each) do
        login_as :admin
        @admin = users(:admin)
        @object = mock_model(User)
        @object.stub!(:current_state).and_return(:active)
        User.stub!(:find_by_id).with(@admin.id).and_return(@admin)
        User.stub!(:find_by_id).with(@object.id).and_return(@object)
      end

      def do_get
        get :show, :id => @object.id
      end

      it "should find the user requested, and assign them for the show template" do
        User.should_receive(:find_by_id).at_least(:once).and_return(@object)
        do_get
        assigns(:object).should equal(@object)
        response.should render_template('show')
      end
    end
    
    describe "as normal users looking at themselves" do
      before(:each) do
        login_as :active_non_admin
        @object = users(:active_non_admin)
        @object.stub!(:current_state).and_return(:active)
        User.stub!(:find_by_id).with(@object.id).and_return(@object)
      end
      
      def do_get
        get :show, :id => @object.id
      end
      
      it "should find their own user, and assign it for the show template" do
        User.should_receive(:find_by_id).at_least(:once).and_return(@object)
        do_get
        assigns(:object).should equal(@object)
        response.should render_template('show')
      end
    end
    
    describe "as normal users trying to peek at others" do
      before(:each) do
        login_as :active_non_admin
        @object = users(:active_non_admin)
        @other_user = mock_model(User)
        @other_user.stub!(:current_state).and_return(:active)
        User.stub!(:find_by_id).with(@other_user.id).and_return(@other_user)
        User.stub!(:find_by_id).with(@object.id).and_return(@object)
      end
      
      def do_get
        get :show, :id => @other_user.id
      end
      
      it "should fail" do
        User.should_not_receive(:find_by_id).with(@other_user.id).and_return(@other_user)
        do_get
        flash[:error].should_not == nil
      end
    end
  end

  describe "handling GET /users/:id.xml" do

    before(:each) do
      login_as :admin
      @admin = users(:admin)
      @object = mock_model(User, :to_xml => "XML")
      User.stub!(:find_by_id).with(@admin.id).at_least(:once).and_return(@admin)
      User.stub!(:find_by_id).with(@object.id).at_least(:once).and_return(@object)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => @object.id
    end

    it "should find the user requested and render as XML" do
      User.should_receive(:find_by_id).with(@admin.id).and_return(@admin)
      User.should_receive(:find_by_id).with(@object.id).at_least(:once).and_return(@object)
      @object.should_receive(:to_xml).and_return("XML")
      do_get
      response.should be_success
      response.body.should == "XML"
    end
  end
  
  describe "handling GET /account" do
    before(:each) do
      login_as :active_non_admin
      @object = users(:active_non_admin)
    end
    
    def do_get
      User.should_receive(:find_by_id).with(@object.id).at_least(:once).and_return(@object)
      get :account
    end
    
    it "should find the current user, and assign it for the show template" do
      do_get
      flash[:error].should == nil
      flash[:warning].should == nil
      assigns(:object).should == @object
      response.should render_template('show')
    end
  end

  describe "handling GET /users/new" do
    describe "while not logged in" do
      before(:each) do
        @object = mock_model(User)
        User.stub!(:new).and_return(@object)
      end

      def do_get
        get :new
      end

      it "should create a new un-saved user and render them in the new template" do
        @object.should_not_receive(:save!)
        User.should_receive(:new).and_return(@object)
        do_get
        response.should be_success
        assigns(:object).should equal(@object)
        response.should render_template('form')
      end
    end
    
    describe "while logged in" do
      describe "as a normal user" do
        before(:each) do
          login_as :active_non_admin
          @object = mock_model(User)
          User.stub!(:new).and_return(@object)
        end

        def do_get
          get :new
        end

        it "should fail" do
          @object.should_not_receive(:save!)
          User.should_not_receive(:new)
          do_get
          flash[:error].should_not == nil
        end
      end
      
      describe "as an administrator" do
        before(:each) do
          login_as :admin
          @object = mock_model(User)
          User.stub!(:new).and_return(@object)
        end

        def do_get
          get :new
        end

        it "should succeed" do
          @object.should_not_receive(:save!)
          User.should_receive(:new).and_return(@object)
          do_get
          response.should be_success
          assigns(:object).should equal(@object)
          response.should render_template('form')
        end
      end
    end
  end

  describe "handling GET /users/:id/edit" do

    before(:each) do
      login_as :active_non_admin
      @object = users(:active_non_admin)
      User.stub!(:find_by_id).with(@object.id).and_return(@object)
    end
  
    def do_get
      get :edit, :id => @object.id
    end
  
    it "should find the user requested and assign it for the edit template" do
      User.should_receive(:find_by_id).with(@object.id).at_least(:once).and_return(@object)
      do_get
      response.should be_success
      response.should render_template('form')
      assigns(:object).should equal(@object)
    end
  end
  
  describe "handling POST /users" do
    describe "in general" do
      def do_post(options)
        post :create, :user => options
      end

      it "should sign up users in the pending state and with an activation code" do
        lambda {
          @controller.should_receive(:create_change_log_entry)
          do_post Factory.valid_user_hash
          assigns(:object).reload
          assigns(:object).current_state.should == :pending
          assigns(:object).activation_code.should_not == nil
        }.should change(User, :count).by(1)
      end

      it "should require a login at signup" do
        lambda {
          @controller.should_not_receive(:create_change_log_entry)
          do_post Factory.valid_user_hash.except(:login)
          assigns(:object).errors.on(:login).should_not == nil
        }.should_not change(User, :count)
      end

      it "should require a password at signup" do
        lambda {
          @controller.should_not_receive(:create_change_log_entry)
          do_post Factory.valid_user_hash.except(:password)
          assigns(:object).errors.on(:password).should_not == nil
        }.should_not change(User, :count)
      end

      it "should require a password confirmation at signup" do
        lambda {
          @controller.should_not_receive(:create_change_log_entry)
          do_post Factory.valid_user_hash.except(:password)
          assigns(:object).errors.on(:password).should_not == nil
        }.should_not change(User, :count)
      end

      it "should require an email at signup" do
        lambda {
          @controller.should_not_receive(:create_change_log_entry)
          do_post Factory.valid_user_hash.except(:email)
          assigns(:object).errors.on(:email).should_not == nil
        }.should_not change(User, :count)
      end
    end

    describe "while not logged in" do
      before(:each) do
        @id = 100
        @object = mock_model(User, :to_param => @id)
        User.stub!(:new).and_return(@object)
      end

      describe "with successful save" do
        def do_post
          errors = mock('errors')
          errors.should_receive(:empty?).and_return(true)
          @object.should_receive(:errors).and_return(errors)
          @object.should_receive(:save!).and_return(true)
          @object.should_receive(:register!).and_return(true)
          @object.should_receive(:valid?).and_return(true)
          @object.should_receive(:login=)
          @object.should_receive(:identity_url=)
          @controller.should_receive(:create_change_log_entry)
          post :create, :user => {}
        end
  
        it "should create a new user and redirect to login" do
          User.should_receive(:new).with({}).and_return(@object)
          do_post
          @object.should_not be_new_record
          response.should redirect_to(login_path)
        end
      end
    
      describe "with failed save" do
        def do_post
          @object.should_not_receive(:save!)
          @object.should_not_receive(:register!)
          @object.should_receive(:valid?).and_return(false)
          @object.should_receive(:login=)
          @object.should_receive(:identity_url=)
          @object.should_not_receive(:create_change_log_entry)
          post :create, :user => {}
        end
  
        it "should re-render 'new'" do
          do_post
          flash[:error].should_not == nil
          response.should render_template('form')
        end
      end
    end
    
    describe "while logged in" do
      before(:each) do
        @id = 100
        @object = mock_model(User, :to_param => @id)
        User.stub!(:new).and_return(@object)
      end

      describe "as a normal user" do
        
        def do_post
          login_as :active_non_admin
          post :create, :user => {}
        end
        
        it "should fail" do
          do_post
          flash[:error].should_not == nil
        end
      end
      
      describe "as an administrator" do
        before(:each) do
          login_as :admin
        end
        
        def do_post
          post :create, :user => {}, :activate => 1
        end
        
        it "should create a new user and redirect to the users path" do
          errors = mock('errors')
          errors.should_receive(:empty?).and_return(true)
          @object.should_receive(:errors).and_return(errors)
          @object.should_receive(:save!).and_return(true)
          @object.should_not_receive(:register!).and_return(true)
          @object.should_receive(:activate!)
          @object.should_receive(:valid?).and_return(true)
          @object.should_receive(:login=)
          @object.should_receive(:identity_url=)
          User.should_receive(:new).and_return(@object)
          do_post
          response.should redirect_to(users_path)
        end
      
        describe "with failed save" do
        
          def do_post
            @object.should_receive(:valid?).and_return(false)
            @object.should_receive(:login=)
            @object.should_receive(:identity_url=)
            post :create, :user => {}
          end
        
          it "should re-render 'new'" do
            do_post
            response.should render_template('form')
          end
        end
      end
    end
  end

  describe "handling PUT /users/:id" do
    describe "as an administrator" do
      before(:each) do
        login_as :admin
        @object = users(:admin)
        User.should_receive(:find_by_id).at_least(:once).and_return(@object)
      end

      def do_put
        put :update, :id => @object.id
      end

      it "should not allow removal of the administrator role" do
        do_put
        flash[:warning].should_not == nil
      end
    end

    describe "of oneself" do
      describe "as a normal user" do
        before(:each) do
          login_as :active_non_admin
          @object = users(:active_non_admin)
          User.stub!(:find_by_id).and_return(@object)
        end

        describe "with successful update" do
          def do_put
            @controller.should_receive(:create_change_log_entry)
            put :update, :id => @object.id
          end

          it "should find the user requested, update and redirect" do
            @object.should_receive(:update_attributes!).and_return(true)
            User.should_receive(:find_by_id).with(@object.id).at_least(:once).and_return(@object)
            do_put
            assigns(:object).should equal(@object)
            response.should redirect_to(user_url(@object.id))
          end
        end

        describe "with failed update" do

          def do_put
            @controller.should_not_receive(:create_change_log_entry)
            @object.errors.stub!(:full_messages).and_return([])
            @object.should_receive(:update_attributes!).and_raise(ActiveRecord::RecordInvalid.new(@object))
            put :update, :id => @object.id
          end

          it "should re-render 'edit'" do
            do_put
            flash[:error].should == nil
            response.should render_template('form')
          end
        end
      end
    end
    
    describe "of another user" do
      describe "as a normal user" do
        before(:each) do
          login_as :active_non_admin
          @object = users(:active_non_admin)
          
          @other_user = mock_model(User)
          User.stub!(:find_by_id).and_return(@other_user)
        end
        
        def do_put
          @controller.should_not_receive(:create_change_log_entry)
          put :update, :id => @other_user.id
        end

        it "should fail" do
          User.should_not_receive(:find_by_id).with(@other_user.id)
          User.should_receive(:find_by_id).with(@object.id).and_return(@object)
          do_put
          flash[:error].should_not == nil
        end
      end
      
      describe "as an administrator" do
        before(:each) do
          login_as :admin
          @admin = users(:admin)
          @object = mock_model(User)
          @object.stub!(:current_state).and_return(:active)
          @object.stub!(:is_administrator?).and_return(false)
          
          User.stub!(:find_by_id).with(@admin.id).at_least(:once).and_return(@admin)
          User.stub!(:find_by_id).and_return(@object)
        end

        describe "with successful update" do
          def do_put
            @controller.should_receive(:create_change_log_entry)
            put :update, :id => @object.id
          end

          it "should update and redirect" do
            User.should_receive(:find_by_id).with(@admin.id).and_return(@admin)
            @object.should_receive(:update_attributes!).and_return(true)
            do_put
            assigns(:object).should equal(@object)
            response.should redirect_to(user_url(@object.id))
          end
        end

        describe "with failed update" do

          def do_put
            @controller.should_not_receive(:create_change_log_entry)
            @object.errors.stub!(:full_messages).and_return([])
            @object.should_receive(:update_attributes!).and_raise(ActiveRecord::RecordInvalid.new(@object))
            put :update, :id => @object.id
          end

          it "should re-render 'edit'" do
            do_put
            flash[:error].should == nil
            response.should render_template('form')
          end
        end
      end
    end
  end
    
  describe "handling DELETE /users/:id/destroy" do

    describe "of oneself" do
      before(:each) do
        login_as :active_non_admin
        @object = users(:active_non_admin)
      end
      
      def do_delete
        @controller.should_receive(:create_change_log_entry)
        delete :destroy, :id => users(:active_non_admin).id
      end

      it "should logout the user" do
        do_delete
        response.session[:user_id].should == nil
      end
    end
    
    describe "of another user" do
      describe "as admin" do
        before(:each) do
          login_as :admin
          @object = users(:active_non_admin)
        end
        
        def do_delete
          @controller.should_receive(:create_change_log_entry)
          delete :destroy, :id => @object.id
        end
        
        it "should delete the user" do
          do_delete
          assigns(:object).current_state.should == :deleted
        end

        it "should redirect to the users list" do
          do_delete
          response.should redirect_to(users_url)
        end
      end
      
      describe "as a normal user" do
        before(:each) do
          login_as :active_non_admin
          @object = users(:pending)
        end
        
        def do_delete
          @controller.should_not_receive(:create_change_log_entry)
          delete :destroy, :id => @object.id
        end
        
        it "should redirect and give permission denied" do
          do_delete
          flash[:error].should_not == nil
          response.response_code.should == 302
        end
      end
    end
  end
  
  describe "handling /users/undelete/:id" do
    describe "as an administrator" do
      before(:each) do
        login_as :admin
        @admin  = users(:admin)
        @object   = users(:deleted)
      end

      def do_put
        @controller.should_receive(:create_change_log_entry)
        put :undelete, :id => @object.id
      end

      it "should find the requested user, undelete!, and redirect to the users path" do
        User.should_receive(:find_by_id).with(@admin.id).and_return(@admin)
        User.should_receive(:find_by_id).with(@object.id).at_least(:once).and_return(@object)
        @object.should_receive(:undelete!)
        do_put
        assigns(:object).should == @object
        response.should redirect_to(users_path)
        flash[:error].should == nil
        flash[:warning].should == nil
        flash[:notice].should == nil
      end
      
      it "should activate the user" do
        do_put
        assigns(:object).current_state.should == :active
      end
    end
    
    describe "as a normal user" do
      before(:each) do
        login_as :active_non_admin
        @active_non_admin = users(:active_non_admin)
        @object             = users(:deleted)
      end

      def do_put
        @controller.should_not_receive(:create_change_log_entry)
        get :undelete, :id => @object.id
      end

      it "should fail" do
        User.should_receive(:find_by_id).with(@active_non_admin.id).and_return(@active_non_admin)
        @object.should_not_receive(:undelete!)
        do_put
        flash[:error].should_not == nil
      end
    end
    
    describe "of a user not in the :deleted state" do
      before(:each) do
        login_as :admin
        @object = users(:admin)
      end

      def do_put
        @controller.should_not_receive(:create_change_log_entry)
        get :undelete, :id => @object.id
      end

      it "should fail" do
        User.should_receive(:find_by_id).at_least(:once).and_return(@object)
        @object.should_not_receive(:undelete!)
        do_put
        flash[:error].should_not == nil
      end
    end
  end

  describe "handling DELETE /users/:id/purge" do
    describe "of a user in the :delted state" do
      describe "as an administrator" do
        before do
          login_as :admin
          @admin = users(:admin)
          @object = users(:deleted)
          User.stub!(:find_by_id).with(@admin.id).and_return(@admin)
          User.stub!(:find_by_id).with(@object.id).and_return(@object)
        end

        def do_delete
          User.should_receive(:find_by_id).with(@admin.id).and_return(@admin)
          User.should_receive(:find_by_id).with(@object.id).at_least(:once).and_return(@object)
          @controller.should_receive(:create_change_log_entry)
          @object.should_receive(:destroy)
          delete :purge, :id => @object.id
        end

        it "should find and destroy the user, and redirect to the user list" do
          do_delete
          flash[:warning].should  == nil
          flash[:error].should    == nil
          response.should redirect_to(users_path)
        end
      end
    
      describe "as a normal user" do
        before do
          login_as :active_non_admin
          @object = users(:active_non_admin)
          User.stub!(:find_by_id).with(@object.id).and_return(@object)
        end

        def do_delete
          User.should_receive(:find_by_id).with(@object.id).and_return(@object)
          @controller.should_not_receive(:create_change_log_entry)
          @object.should_not_receive(:destroy)
          delete :purge, :id => @object.id
        end

        it "should fail" do
          do_delete
          flash[:error].should_not == nil
        end
      end
      
      describe "who is an administrator" do
        before do
          login_as :admin
          @admin = users(:admin)
          
          # let's mock the deleted user as an administrator
          admin_role = roles(:administrator)
          roles = [admin_role]
          roles.stub!(:find_by_title).with('administrator').and_return(admin_role)
          
          @object = users(:deleted)
          @object.stub!(:roles).and_return(roles)
          User.stub!(:find_by_id).with(@admin.id).and_return(@admin)
          User.stub!(:find_by_id).with(@object.id).and_return(@object)
        end

        def do_delete
          User.should_receive(:find_by_id).with(@admin.id).and_return(@admin)
          User.should_receive(:find_by_id).with(@object.id).at_least(:once).and_return(@object)
          @controller.should_not_receive(:create_change_log_entry)
          @object.should_not_receive(:destroy)
          delete :purge, :id => @object.id
        end

        it "should fail" do
          do_delete
          flash[:warning].should_not == nil
        end
      end
    end
    describe "of a user not in the :deleted state" do
      before do
        login_as :admin
        @object = users(:active_non_admin)
        @admin = users(:admin)
      end

      def do_delete
        User.should_receive(:find_by_id).with(@admin.id).and_return(@admin)
        User.should_receive(:find_by_id).with(@object.id).at_least(:once).and_return(@object)
        @controller.should_not_receive(:create_change_log_entry)
        @object.should_not_receive(:destroy)
        delete :purge, :id => @object.id
      end

      it "should fail" do
        do_delete
        flash[:error].should_not  == nil
        response.should redirect_to(users_path)
      end
    end
  end
  
  describe "handling GET /activate" do
    before(:each) do
      @object = users(:pending)
    end
    
    it "should activate the user" do
      User.authenticate(@object.login, 'foobar').should == nil
      get :activate, :code => @object.activation_code
      response.should redirect_to(login_path)
      flash[:notice].should_not == nil if flash[:error].blank?
      flash[:error].should_not == nil if flash[:notice].blank?
      User.authenticate('pending', 'foobar').should == @object
    end
    
    it "should not activate the user without a key" do
      get :activate
      flash[:error].should_not == nil
      flash[:notice].should == nil
    end
    
    it "should not activate a user with a blank key" do
      get :activate, :code => ''
      flash[:error].should_not == nil
      flash[:notice].should == nil
    end
    
    it "should not activate a user with an invalid key" do
      get :activate, :code => 'iliketopoop'
      flash[:error].should_not == nil
      flash[:notice].should == nil
    end
  end
  
  describe "handling PUT /prepare_password_reset" do
    def do_put(email = 'active@non-admin.com')
      put :prepare_password_reset, :email => email
    end
    
    it "should redirect to the login form" do
      do_put
      flash[:error].should        == nil
      flash[:warning].should      == nil
      flash[:notice].should_not   == nil
      response.should redirect_to(login_path)
    end
    
    it "should only process users in active or forgetful states" do
      do_put 'user@pending.activation.com'
      flash[:error].should_not  == nil
      flash[:warning].should    == nil
      flash[:notice].should     == nil
      response.should redirect_to(forgot_password_path)
    end
    
    it "should not process without an email" do
      do_put nil
      flash[:error].should_not    == nil
      flash[:warning].should      == nil
      flash[:notice].should       == nil
      response.should redirect_to(forgot_password_path)
    end
    
    it "should not process blank emails" do
      do_put ''
      flash[:error].should_not    == nil
      flash[:warning].should      == nil
      flash[:notice].should       == nil
      response.should redirect_to(forgot_password_path)
    end
    
    it "should not process a user with an email not in the database" do
      do_put 'some@email.not.in.db.co.uk'
      flash[:error].should        == nil
      flash[:warning].should_not  == nil
      flash[:notice].should       == nil
      response.should redirect_to(forgot_password_path)
    end
  end
  
  describe "handling GET /reset_password" do
    it "should show the reset form" do
      get :reset_password, :code => '8f24789ae988411ccf33ab0c30fe9106fab32e9a'
      flash[:error].should == nil
      response.should render_template('reset_password')
    end
    
    it "should not show the reset form without a code" do
      get :reset_password
      flash[:error].should_not == nil
      flash[:notice].should == nil
    end
    
    it "should not show the reset form with a blank code" do
      get :reset_password, :code => ''
      flash[:error].should_not == nil
      flash[:notice].should == nil
    end
  end
  
  describe "handling PUT /do_reset" do

    before(:each) do
      @object = users(:forgot)
      User.should_receive(:find_in_state).with(:first, :forgetful, :conditions => {:password_reset_code => @object.password_reset_code}).and_return(@object)
    end
    
    describe "with successful reset" do
      def do_put
        @object.should_receive(:update_attributes).and_return(true)
        @object.should_receive(:remember!).and_return(true)
        put :do_reset, :code => @object.password_reset_code
      end
      
      it "should update the found user and redirect to login" do
        do_put
        assigns(:object).should equal(@object)
        response.should redirect_to(login_path)
      end
    end
    
    describe "with failed reset" do
      def do_put
        @object.should_receive(:update_attributes).and_return(false)
        put :do_reset, :code => @object.password_reset_code
      end
      
      it "should redirect to the forgot_password form" do
        do_put
        response.should redirect_to(forgot_password_path)
      end
      
    end
  end
  
  describe "handling /suspend" do
    describe "while logged in as admin" do
      before(:each) do
        login_as :admin
        @admin  = users(:admin)
        @object = users(:active_non_admin)
      end
      
      def do_put
        @controller.should_receive(:create_change_log_entry)
        put :suspend, :id => @object.id
      end
      
      it "should trigger the suspend! event" do
        User.should_receive(:find_by_id).with(@admin.id).and_return(@admin)
        User.should_receive(:find_by_id).with(@object.id).at_least(:once).and_return(@object)
        @object.should_receive(:suspend!).once
        do_put
        response.should redirect_to(users_path)
      end
      
      it "should suspend the user" do
        do_put
        assigns(:object).current_state.should == :suspended
      end
    end
    
    describe "while logged in as a normal user" do
      before(:each) do
        login_as :active_non_admin
        @object = users(:active_non_admin)
      end
      
      def do_put
        @controller.should_not_receive(:create_change_log_entry)
        put :suspend, :id => @object.id
      end
      
      it "should fail" do
        User.should_receive(:find_by_id).at_least(:once).and_return(@object)
        @object.should_not_receive(:suspend!)
        do_put
        flash[:error].should_not == nil
      end
    end
    
    describe "while not logged in" do
      before(:each) do
        @object = users(:active_non_admin)
      end
      
      def do_put
        @controller.should_not_receive(:create_change_log_entry)
        put :suspend, :id => @object.id
      end
      
      it "should fail" do
        User.should_not_receive(:find_by_id)
        @object.should_not_receive(:suspend!)
        do_put
        flash[:error].should_not == nil
        response.should redirect_to(login_path)
      end
    end
  end
  
  describe "handling /unsuspend" do
    describe "while logged in as admin" do
      before(:each) do
        login_as :admin
        @admin  = users(:admin)
        @object = users(:suspended)
      end
      
      def do_put
        @controller.should_receive(:create_change_log_entry)
        put :unsuspend, :id => @object.id
      end
      
      it "should trigger the unsuspend! event" do
        User.should_receive(:find_by_id).with(@admin.id).and_return(@admin)
        User.should_receive(:find_by_id).with(@object.id).at_least(:once).and_return(@object)
        @object.should_receive(:unsuspend!).once
        do_put
        response.should redirect_to(users_path)
      end
      
      it "should activate the user" do
        do_put
        assigns(:object).current_state.should == :active
      end
    end
    
    describe "while logged in as a normal user" do
      before(:each) do
        login_as :active_non_admin
        @object = users(:active_non_admin)
      end
      
      def do_put
        @controller.should_not_receive(:create_change_log_entry)
        put :unsuspend, :id => @object.id
      end
      
      it "should fail" do
        User.should_receive(:find_by_id).at_least(:once).and_return(@object)
        @object.should_not_receive(:unsuspend!)
        do_put
        flash[:error].should_not == nil
      end
    end
    
    describe "of a user not in the suspended state" do
      before(:each) do
        login_as :admin
        @admin  = users(:admin)
        @object = users(:active_non_admin)
      end
      
      def do_put
        @controller.should_not_receive(:create_change_log_entry)
        put :unsuspend, :id => @object.id
      end
      
      it "should fail due to invalid state" do
        do_put
        flash[:error].should_not == nil
      end
    end
  end
end
