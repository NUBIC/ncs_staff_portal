require 'spec_helper'

describe ManagementTask do
  before(:each) do
    @task = ManagementTask.new
  end
  describe "validations" do
    describe "task_date"do
      it "shoud be invalid if nil" do
        @task.task_date = nil
        @task.should_not be_valid
        @task.should have(1).error_on(:task_date)
      end
      it "should accept the string with date as date" do
        @task.task_date = "06/30/2011"
        @task.should be_valid
      end
    end
    it "tasktype_code shoud be invalid if nil" do
      @task.task_type_code = nil
      @task.should_not be_valid
      @task.should have(1).error_on(:task_type_code)
    end
    describe "hours" do
      it "should not contain other than decimal value" do
        @task.hours = "test"
        @task.should_not be_valid
        @task.should have(1).error_on(:hours)
      end
      it "should not be greater than 24 hours" do
        @task.hours = 25.00
        @task.should_not be_valid
        @task.should have(1).error_on(:hours)
      end
      it "should be greater than 0 hours" do
        @task.hours = -3
        @task.should_not be_valid
        @task.should have(1).error_on(:hours)
      end
    end
    describe "expenses" do
      it "should not contain other than decimal value" do
        @task.expenses = "test"
        @task.should_not be_valid
        @task.should have(1).error_on(:expenses)
      end
      it "should not be greater than 99999999.99" do
        @task.expenses = 100000000
        @task.should_not be_valid
        @task.should have(1).error_on(:expenses)
      end
      it "should be greater than $ 0 expenses" do
        @task.expenses= -3
        @task.should_not be_valid
        @task.should have(1).error_on(:expenses)
      end
    end
    describe "miles" do
      it "should not contain other than decimal value" do
        @task.miles = "test"
        @task.should_not be_valid
        @task.should have(1).error_on(:miles)
      end
      it "should not be greater than 999.99" do
        @task.miles = 1000
        @task.should_not be_valid
        @task.should have(1).error_on(:miles)
      end
      it "should be greater than 0 miles" do
        @task.miles = -3
        @task.should_not be_valid
        @task.should have(1).error_on(:miles)
      end
    end
  end
end
