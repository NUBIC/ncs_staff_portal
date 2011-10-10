require 'spec_helper'

describe InitialUserLoader do
  describe "create" do
    before(:each) do
      @role = Role.find_by_name(Role::USER_ADMINISTRATOR)
      @role = FactoryGirl.create(:role, :name => "User Administrator") unless @role
    end

    it "new user and assign 'User Administrator' role if user with username does not exist" do
      user = Staff.find_by_username("testuser")
      user.should be_nil
      user = InitialUserLoader.create
      user.should_not be_nil
      user.username.should == "testuser"
      user.roles.should include @role
    end

    it "assigns 'User Administrator' role if existing user has no 'User Administrator' role" do
      user = Staff.create!(:username => "testuser", :validate_create => "false")
      user.should_not be_nil
      user.roles.should_not include @role
      user = InitialUserLoader.create
      user.roles.should include @role
    end

    it "does nothing if existing user has 'User Administrator' role" do
      user = Staff.create!(:username => "testuser", :validate_create => "false")
      user.roles << @role
      user = InitialUserLoader.create
    end

  end
end
