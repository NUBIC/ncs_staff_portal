require 'spec_helper'

describe StaffPortal do
  before do
    @staff  = FactoryGirl.create(:staff, :username => "lee", :first_name => "Lee", :last_name => "Scott", :email => "scott@test.com")
    @role = Factory(:role, :name => "Outreach staff")
    FactoryGirl.create(:staff_role, :role => @role, :staff => @staff)
    @staff_portal = Aker::Authorities::StaffPortal.new
  end

  describe "user" do
    before do
      @return_user = @staff_portal.user("lee");
    end

    it "copies first name from NCS Navigator Ops user" do
      @return_user.first_name.should == @staff.first_name
    end

    it "copies last name from NCS Navigator Ops user" do
      @return_user.last_name.should == @staff.last_name
    end

    it "copies email from NCS Navigator Ops user" do
      @return_user.email.should == @staff.email
    end

    it "generate group membership from staff role" do
      @return_user.group_memberships(:NCSNavigator).include?(@role.name).should be_true
    end
  end

  describe "#amplify!" do
    before do
      @staff_portal.user("lee")

      @before_lee = Aker::User.new("lee")
    end

    def actual
      @staff_portal.amplify!(@before_lee)
    end

    it "does nothing for an unknown user" do
      lambda { @staff_portal.amplify!(Aker::User.new("lees")) }.should_not raise_error
    end

    it "copies simple attributes" do
      actual.first_name.should == "Lee"
    end

    it "copies portal" do
      actual.portals.should == [:NCSNavigator]
    end

    it "copies group memberships" do
      actual.group_memberships(:NCSNavigator).size.should == 1
    end

    it "contains correct group" do
      actual.group_memberships(:NCSNavigator).include?("Outreach Staff").should be_true
    end
  end
end
