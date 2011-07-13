require 'spec_helper'

describe StaffWeeklyExpense do
  it "should create a new instance given valid attributes" do
    expense = Factory(:staff_weekly_expense)
    expense.should_not be_nil
  end
  
  it { should validate_presence_of(:week_start_date) }
  
  it { should belong_to(:staff) }
end
