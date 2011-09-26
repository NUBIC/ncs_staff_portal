require 'spec_helper'

describe Role do
  it "should create a new instance given valid attributes" do
    role = Factory(:role)
    role.should_not be_nil
  end
  
  it { should validate_presence_of(:name) }

  it "should require name to be unique" do
    role = FactoryGirl.create(:role, :name => "testing")
    role1 = FactoryGirl.build(:role, :name => "testing")
    role1.save
    role1.should_not be_valid
  end
end
