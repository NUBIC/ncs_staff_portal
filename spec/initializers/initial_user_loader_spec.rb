require 'spec_helper'

describe InitialUserLoader do
  describe "create" do
    before(:each) do
      @user_admin_role = Role.find_by_name(Role::USER_ADMINISTRATOR)
      @user_admin_role = FactoryGirl.create(:role, :name => "User Administrator") unless @user_admin_role
      @sys_admin_role = Role.find_by_name(Role::SYSTEM_ADMINISTRATOR)
      @sys_admin_role = FactoryGirl.create(:role, :name => "System Administrator") unless @sys_admin_role
    end

    it "new user and assign 'User Administrator' and 'System Administrator' role if user with username does not exist" do
      user = Staff.find_by_username("testuser")
      user.should be_nil
      user = InitialUserLoader.create
      user.should_not be_nil
      user.username.should == "testuser"
      user.roles.should include @user_admin_role
      user.roles.should include @sys_admin_role
    end

    it "assigns 'User Administrator' role if existing user has no 'User Administrator' role" do
      user = Staff.create!(:username => "testuser", :validate_create => "false")
      user.should_not be_nil
      user.roles.should_not include @user_admin_role
      user = InitialUserLoader.create
      user.roles.should include @user_admin_role
    end
    
    it "assigns 'System Administrator' role if existing user has no 'System Administrator' role" do
      user = Staff.create!(:username => "testuser", :validate_create => "false")
      user.should_not be_nil
      user.roles.should_not include @sys_admin_role
      user = InitialUserLoader.create
      user.roles.should include @sys_admin_role
    end

    it "does nothing if existing user has 'User Administrator' and 'System Administrator' role" do
      user = Staff.create!(:username => "testuser", :validate_create => "false")
      user.roles << @user_admin_role
      user = InitialUserLoader.create
    end

  end
end
