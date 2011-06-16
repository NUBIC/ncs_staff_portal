require 'spec_helper'

describe Staff do
  before(:each) do
    @staff = Staff.new(:name => "Testing", 
                 :netid => "test123",
                 :email => "test@test.com",
                 :study_center => 123456)
  end
  describe "hourly_rate validations" do
    it "should not contain other than decimal value" do
      @staff.hourly_rate = "test"
      @staff.should_not be_valid
      @staff.should have(1).error_on(:hourly_rate)
    end
    it "should be greater than 0 dollar" do
      @staff.hourly_rate = -3
      @staff.should_not be_valid
      @staff.should have(1).error_on(:hourly_rate)
    end
  end
  
  describe "calculate_hourly_rate" do
    it "should put pay_amount as it is as hourly_rate if pay_type is 'hourly'" do
      @staff.pay_type = "Hourly"
      @staff.pay_amount = 25.00
      @staff.save
      @staff.hourly_rate.should == 25.00
    end
  end
end
