# == Schema Information
#
# Table name: miscellaneous_expenses
#
#  id                      :integer         not null, primary key
#  staff_weekly_expense_id :integer
#  expense_date            :date
#  expenses                :decimal(10, 2)
#  miles                   :decimal(5, 2)
#  staff_misc_exp_id       :string(36)      not null
#  comment                 :text
#  created_at              :datetime
#  updated_at              :datetime
#  hours                   :decimal(10, 2)
#

require 'spec_helper'

describe MiscellaneousExpense do
  it "should create a new instance given valid attributes" do
    task = Factory(:miscellaneous_expense)
    task.should_not be_nil
  end

  it { should belong_to(:staff_weekly_expense) }

  describe '#public_id' do
    it 'is :staff_misc_exp_id' do
      MiscellaneousExpense.new(:staff_misc_exp_id => 'fred').public_id.should == 'fred'
    end
  end

  describe "validations" do
    describe "hours" do
      it "should not contain other than decimal value" do
        task= FactoryGirl.build(:miscellaneous_expense, :hours => "test")
        task.should_not be_valid
        task.should have(1).error_on(:hours)
      end

      it "should not be greater than 99 hours" do
        task= FactoryGirl.build(:miscellaneous_expense, :hours => 100)
        task.should_not be_valid
        task.should have(1).error_on(:hours)
      end

      it "should be positive value" do
        task= FactoryGirl.build(:miscellaneous_expense, :hours => -3)
        task.should_not be_valid
        task.should have(1).error_on(:hours)
      end
      
      it "should allow value to be 0" do
        task= FactoryGirl.build(:miscellaneous_expense, :hours => 0)
        task.should be_valid
      end
    end

    describe "expenses" do
      it "should not contain other than decimal value" do
        task= FactoryGirl.build(:miscellaneous_expense, :expenses => "test")
        task.should_not be_valid
        task.should have(1).error_on(:expenses)
      end

      it "should not be greater than 99999999.99" do
        task= FactoryGirl.build(:miscellaneous_expense, :expenses => 100000000)
        task.should_not be_valid
        task.should have(1).error_on(:expenses)
      end

      it "should be positive value" do
        task= FactoryGirl.build(:miscellaneous_expense, :expenses => -3)
        task.should_not be_valid
        task.should have(1).error_on(:expenses)
      end
      
      it "should allow value to be 0" do
        task= FactoryGirl.build(:miscellaneous_expense, :expenses => 0)
        task.should be_valid
      end
    end

    describe "miles" do
      it "should not contain other than decimal value" do
        task= FactoryGirl.build(:miscellaneous_expense, :miles => "test")
        task.should_not be_valid
        task.should have(1).error_on(:miles)
      end

      it "should not be greater than 999.99" do
        task= FactoryGirl.build(:miscellaneous_expense, :miles => 1000)
        task.miles = 1000
        task.should_not be_valid
        task.should have(1).error_on(:miles)
      end

      it "should be positive value" do
        task= FactoryGirl.build(:miscellaneous_expense, :miles => -3)
        task.should_not be_valid
        task.should have(1).error_on(:miles)
      end
      
      it "should allow value to be 0" do
        task= FactoryGirl.build(:miscellaneous_expense, :miles => 0)
        task.should be_valid
      end
    end

    describe "task_date" do
      it "should not be blank" do
        task= FactoryGirl.build(:miscellaneous_expense, :expense_date => nil)
        task.should_not be_valid
        task.should have(1).error_on(:expense_date)
      end
    end
  end
end
