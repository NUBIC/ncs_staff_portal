require 'spec_helper'

describe Staff do
  before(:each) do
    @staff = Staff.create(:name => "Testing", 
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
end
