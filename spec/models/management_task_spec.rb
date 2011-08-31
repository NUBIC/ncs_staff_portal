require 'spec_helper'

describe ManagementTask do
  it "should create a new instance given valid attributes" do
    task = Factory(:management_task)
    task.should_not be_nil
  end
  
  it { should validate_presence_of(:task_type) }
  
  it { should belong_to(:staff_weekly_expense) }
   
  it { should belong_to(:task_type) }
  
  describe "validations" do
    describe "hours" do
      it "should not contain other than decimal value" do
        task= FactoryGirl.build(:management_task, :hours => "test")
        task.should_not be_valid
        task.should have(1).error_on(:hours)
      end
      it "should not be greater than 99 hours" do
        task= FactoryGirl.build(:management_task, :hours => 100)
        task.should_not be_valid
        task.should have(1).error_on(:hours)
      end
      it "should be greater than 0 hours" do
        task= FactoryGirl.build(:management_task, :hours => -3)
        task.should_not be_valid
        task.should have(1).error_on(:hours)
      end
    end
    describe "expenses" do
      it "should not contain other than decimal value" do
        task= FactoryGirl.build(:management_task, :expenses => "test")
        task.should_not be_valid
        task.should have(1).error_on(:expenses)
      end
      it "should not be greater than 99999999.99" do
        task= FactoryGirl.build(:management_task, :expenses => 100000000)
        task.should_not be_valid
        task.should have(1).error_on(:expenses)
      end
      it "should be greater than $ 0 expenses" do
        task= FactoryGirl.build(:management_task, :expenses => -3)
        task.should_not be_valid
        task.should have(1).error_on(:expenses)
      end
    end
    describe "miles" do
      it "should not contain other than decimal value" do
        task= FactoryGirl.build(:management_task, :miles => "test")
        task.should_not be_valid
        task.should have(1).error_on(:miles)
      end
      it "should not be greater than 999.99" do
        task= FactoryGirl.build(:management_task, :miles => 1000)
        task.miles = 1000
        task.should_not be_valid
        task.should have(1).error_on(:miles)
      end
      it "should be greater than 0 miles" do
        task= FactoryGirl.build(:management_task, :miles => -3)
        task.should_not be_valid
        task.should have(1).error_on(:miles)
      end
    end
    describe "task_date" do
      it "should not be blank" do
        task= FactoryGirl.build(:management_task, :task_date => nil)
        task.should_not be_valid
        task.should have(1).error_on(:task_date)
      end
    end
  end
end
