# == Schema Information
#
# Table name: roles
#
#  id   :integer          not null, primary key
#  name :string(255)      not null
#

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

  describe '.create_all' do
    it 'ensures all roles are present in the database' do
      Role.create_all

      Role.count.should == 10
    end

    it 'does not create duplicate roles' do
      Role.create!(:name => 'System Administrator')

      Role.create_all

      Role.count.should == 10
    end
  end
end
