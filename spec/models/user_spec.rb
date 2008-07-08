require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  fixtures :users, :roles, :pages, :change_logs
  
  describe "checking if a user exists" do
    it "should return false if passed nil" do
      User.exists?(nil).should == false
    end
    
    it "should return false if passed an invalid id" do
      User.exists?(0000).should == false
    end
    
    it "should return false if not passed an Integer or User" do
      User.exists?(users(:admin).id.to_s).should == false
    end
    
    it "should return true if a user in the system" do
      User.exists?(users(:admin)).should == true
    end
    
    it "should return true if the id of a user in the system" do
      User.exists?(users(:admin).id).should == true
    end
  end
  
  describe "acessing change_log utility timestamp functions" do
    describe "on a suspended user" do
      before(:each) do
        @object = users(:suspended)
      end
      
      it "should have a suspension date" do
        @object.suspended_at.should_not == nil
      end
    end
    
    describe "on an active user" do
      before(:each) do
        @object = users(:active_non_admin)
      end
      
      it "should have an activation date" do
        @object.activated_at.should_not == nil
      end
    end
    
    describe "on an updated user" do
      before(:each) do
        @object = users(:active_non_admin)
      end
      
      it "should have an updated date" do
        @object.updated_at.should_not == nil
      end
    end
    
    describe "on a deleted user" do
      before(:each) do
        @object = users(:deleted)
      end
      
      it "should have a deletion date" do
        @object.deleted_at.should_not == nil
      end
    end
    
    describe "on an unsuspended user" do
      before(:each) do
        @object = users(:active_non_admin)
      end
      
      it "should have an unsuspend date" do
        @object.unsuspended_at.should_not == nil
      end
    end
  end
  
  describe "having been registered" do
    it "should change the User count" do
      @user = User.build
      lambda {@user.register!}.should change(User, :count).by(1)
    end
    
    it "should enter the pending state" do
      @user = User.build!
      @user.register! if @user.valid?
      @user.current_state.should == :pending
    end
    
    it "should initialize the user's activation_code" do
      @user = User.build!
      @user.register! if @user.valid?
      @user.activation_code.should_not == nil
    end
    
    it "requires a login" do
      lambda {
        @user = User.build :login => nil
        @user.register! if @user.valid?
        @user.errors.on(:login).should_not == nil
      }.should_not change(User, :count)
    end
    
    it "requires a unique login" do
      lambda {
        @user = User.build :login => users(:admin).login
        @user.register! if @user.valid?
        @user.errors.on(:login).should_not == nil
      }.should_not change(User, :count)
    end
    
    it "requires an email" do
      lambda {
        @user = User.build :email => nil
        @user.register! if @user.valid?
        @user.errors.on(:email).should_not == nil
      }.should_not change(User, :count)
    end
    
    it "requires a unique email" do
      lambda {
        @user = User.build :email => users(:admin).email
        @user.register! if @user.valid?
        @user.errors.on(:email).should_not == nil
      }.should_not change(User, :count)
    end
    
    it "requires a password" do
      lambda {
        @user = User.build :password => nil
        @user.register! if @user.valid?
        @user.errors.on(:password).should_not == nil
      }.should_not change(User, :count)
    end
    
    it "requires a password confirmation" do
      lambda {
        @user = User.build :password_confirmation => nil
        @user.register! if @user.valid?
        @user.errors.on(:password_confirmation).should_not == nil
      }.should_not change(User, :count)
    end
    
    it "is passive if without a password" do
      @user = User.build :password => nil, :password_confirmation => nil
      @user.register! if @user.valid?
      @user.current_state.should == :passive
      @user.update_attributes!(:password => 'new_password', :password_confirmation => 'new_password')
      @user.register! if @user.valid?
      @user.current_state.should == :pending
    end
    
    it "should reset a password" do
      @user = users(:active_non_admin)
      @user.update_attributes!({
        :password              => 'new_password',
        :password_confirmation => 'new_password'
      })
      User.authenticate(@user.login, 'new_password').should == @user
    end
    
    it "encrypts password" do
      @user = User.build
      @user.crypted_password.should be_blank
      @user.register! if @user.valid?
      @user.crypted_password.should_not be_blank
    end
    
    it "should be suspendable" do
      @user = User.build!
      @user.register! if @user.valid?
      @user.suspend!
      @user.current_state.should == :suspended
    end
    
    it "should be pacifiable" do
      @user = User.build!
      @user.register! if @user.valid?
      @user.pacify!
      @user.current_state.should == :passive
    end
    
    it "should be deletable" do
      @user = User.build!
      @user.register! if @user.valid?
      @user.delete!
      @user.current_state.should == :deleted
    end
    
    it "should be able to identify its own roles by string or Role" do
      @user = users(:admin)
      @user.has_role?("user").should                be_false
      @user.has_role?(roles(:user)).should          be_false
      @user.has_role?("administrator").should       be_true
      @user.has_role?(roles(:administrator)).should be_true
    end
    
    it "should start with zero roles" do
      @user = User.build!
      @user.roles.should == []
    end
    
    it "should not start with the admin role" do
      admin_role = roles(:administrator)
      
      @user = User.build!
      @user.roles.should_not include(admin_role)
    end
    
    it "should return false on a bad has_role? call" do
      @user = User.build!
      @user.has_role?(1).should be_false
    end
    
    it "should have a 'name' function" do
      @user = User.build!
      @user.name.should == @user.first_name + ' ' + @user.last_name
    end
  end
  
  describe "being unsuspended" do
    it "should revert to the active state" do
      @user = users(:suspended)
      @user.unsuspend!
      @user.current_state.should == :active
    end

    it 'should revert to passive if activation_code and activated_at are nil' do
      @user = User.build!
      @user.register!
      @user.activate!
      @user.suspend!
      @user.activation_code.should == nil
      @user.unsuspend!
      @user.current_state.should == :passive
    end
    
    it 'should revert to pending if activation_code is set and activated_at is nil' do
      @user = User.build!
      @user.register!
      @user.suspend!
      @user.activation_code.should_not == nil
      @user.unsuspend!
      @user.current_state.should == :pending
    end
  end
  
  describe "being remembered via cookies" do
    before(:each) do
      @user = User.build!
    end
    
    it "should set the remember me token" do
      @user.remember_me
      @user.remember_token.should_not == nil
    end
    
    it "should be able to unset the remember me token" do
      @user.remember_me
      @user.remember_token.should_not == nil
      @user.forget_me
      @user.remember_token.should == nil
    end
    
    it "should remember me for 1 week" do
      before = 1.week.from_now.utc
      @user.remember_me_for 1.week
      after = 1.week.from_now.utc
      @user.remember_token.should_not == nil
      @user.remember_token_expires_at.should_not == nil
      @user.remember_token_expires_at.between?(before, after).should == true
    end
    
    it "should remember me until 1 week" do
      time = 1.week.from_now.utc
      @user.remember_me_until time
      @user.remember_token.should_not == nil
      @user.remember_token_expires_at.should_not == nil
      @user.remember_token_expires_at.should == time
    end
    
    it "should remember me for 2 weeks by default" do
      before = 2.weeks.from_now.utc
      @user.remember_me
      after = 2.weeks.from_now.utc
      @user.remember_token.should_not == nil
      @user.remember_token_expires_at.should_not == nil
      @user.remember_token_expires_at.between?(before, after).should == true
    end
    
    it "should be able to refresh their token" do
      @user.remember_me
      token = @user.remember_token
      @user.refresh_token
      @user.remember_token.should_not == token
    end
  end
  
  describe "forgetting their password" do
    before(:each) do
      @user = User.build!
      @user.forget!
    end
    
    it "should transition them to the forgetful state" do
      @user.current_state.should == :forgetful
    end
    
    it "should initialize the user's password_reset_code" do
      @user.password_reset_code.should_not == nil
    end
    
    it "should clear the password_reset_code once re-activated" do
      @user.remember!
      @user.password_reset_code.should == nil
      @user.current_state.should == :active
    end
  end
  
  describe "authorizing for" do
    describe "a secured page" do
      before(:each) do
        @page = pages(:secured)
      end
    
      describe "as an administrator" do
        before(:each) do
          @user = users(:admin)
        end
      
        it "should pass" do
          User.authorized_for_page?(@user, @page).should == true
        end
      end
    
      describe "as a normal user" do
        before(:each) do
          @user = users(:active_non_admin)
        end
      
        it "should not pass" do
          User.authorized_for_page?(@user, @page).should == false
        end
      end
      
      describe "while not logged in" do
        before(:each) do
          @user = nil
        end
      
        it "should not pass" do
          User.authorized_for_page?(@user, @page).should == false
        end
      end
    end
    
    describe "an unsecured page" do
      before(:each) do
        @page = pages(:unsecured)
      end
    
      describe "as an administrator" do
        before(:each) do
          @user = users(:admin)
        end
      
        it "should pass" do
          User.authorized_for_page?(@user, @page).should == true
        end
      end
    
      describe "as a normal user" do
        before(:each) do
          @user = users(:active_non_admin)
        end
      
        it "should pass" do
          User.authorized_for_page?(@user, @page).should == true
        end
      end
      
      describe "while not logged in" do
        before(:each) do
          @user = nil
        end
      
        it "should pass" do
          User.authorized_for_page?(@user, @page).should == true
        end
      end
    end
  end

protected
  def create_registered_user(options = {})
    user = User.build!(options)
    user.register! if user.valid?
    user
  end
  
  def create_passive_user(options = {})
    User.build!({:login => 'dave@djn2ms.com', :first_name => nil, :last_name => nil, :password => nil, :password_confirmation => nil}.merge(options))
  end
end
