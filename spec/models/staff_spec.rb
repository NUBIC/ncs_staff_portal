require 'spec_helper'

describe Staff do
  describe "hourly_rate validations" do
    it "should not contain other than decimal value" do
      staff= FactoryGirl.build(:staff)
      staff.hourly_rate = "test"
      staff.should_not be_valid
      staff.should have(1).error_on(:hourly_rate)
    end
    it "should be greater than 0 dollar" do
      staff= FactoryGirl.build(:staff)
      staff.hourly_rate = -3
      staff.should_not be_valid
      staff.should have(1).error_on(:hourly_rate)
    end
  end
  
  describe "calculate_hourly_rate" do
    it "should put pay_amount as it is as hourly_rate if pay_type is 'Hourly'" do
      staff= FactoryGirl.build(:staff)
      staff.pay_type = "Hourly"
      staff.pay_amount = 25.00
      staff.save
      staff.hourly_rate.should == 25.00
    end
    
    it "should put pay_amount as 'amount/no.of hours worked in year' if pay_type is 'Yearly'" do
      staff= FactoryGirl.build(:staff)
      staff.pay_type = "Yearly"
      staff.pay_amount = 50000
      staff.save
      staff.hourly_rate.should == 28.57
    end
  end
  
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:username) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:study_center) }
end
