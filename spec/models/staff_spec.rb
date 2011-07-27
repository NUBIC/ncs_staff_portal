require 'spec_helper'

describe Staff do
  
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
    
    it "should not calculate the hourly_rate if pay_amount is nil" do
      staff= FactoryGirl.build(:staff)
      staff.pay_type = "Yearly"
      staff.save
      staff.hourly_rate.should be_nil
    end
    
    it "should not calculate the hourly_rate if pay_amount is nil" do
      staff= FactoryGirl.build(:staff)
      staff.pay_amount = 50000
      staff.save
      staff.hourly_rate.should be_nil
    end
  end
  
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:username) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:study_center) }
  
  describe "weekly_task_reminder" do
    before(:each) do
      @staff1 = FactoryGirl.create(:staff, :name => "test1", :username => "test1", :email => "test1@test.com")
      @staff2 = FactoryGirl.create(:staff, :name => "test2", :username => "test2", :email => "test2@test.com")
      @staff3 = FactoryGirl.create(:staff, :name => "test3", :username => "test3", :email => "test3@test.com")
      @staff4 = FactoryGirl.create(:staff, :name => "test4", :username => "test4", :email => "test4@test.com")
    
      @staff3.staff_weekly_expenses.create(:week_start_date => Date.today.monday)
      @staff2.staff_weekly_expenses.create(:week_start_date => (Date.today - 1.week).monday)
      @staff1.staff_weekly_expenses.create(:week_start_date => (Date.today - 1.week).monday)
    end
    it "should return all the staff with no weekly task entry for the current week" do
      expected_staff = Staff.by_task_reminder(Date.today)
      expected_staff[0].should == @staff1
      expected_staff[1].should == @staff2
      expected_staff[2].should == @staff4
    end
    
    it "should return all the staff with no weekly task entry for the previous week" do
      expected_staff = Staff.by_task_reminder(Date.today - 1.week)
      expected_staff[0].should == @staff3
      expected_staff[1].should == @staff4
    end
  end
  
  describe "pay_amount" do
    it "should not contain other than decimal value" do
      staff= FactoryGirl.build(:staff)
      staff.pay_amount = "25,00"
      staff.should_not be_valid
      staff.should have(1).error_on(:pay_amount)
    end
    
    it "should be greater than 0 dollar" do
      staff= FactoryGirl.build(:staff)
      staff.pay_amount = -3
      staff.should_not be_valid
      staff.should have(1).error_on(:pay_amount)
    end
  end 
  
end
