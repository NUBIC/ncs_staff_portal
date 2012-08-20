# == Schema Information
#
# Table name: staff_weekly_expenses
#
#  id              :integer         not null, primary key
#  staff_id        :integer
#  week_start_date :date            not null
#  rate            :decimal(5, 2)
#  comment         :text
#  created_at      :datetime
#  updated_at      :datetime
#  weekly_exp_id   :string(36)      not null
#  hours           :decimal(10, 2)
#  miles           :decimal(10, 2)
#  expenses        :decimal(10, 2)
#

require 'spec_helper'

describe StaffWeeklyExpense do
  it "should create a new instance given valid attributes" do
    expense = Factory(:staff_weekly_expense)
    expense.should_not be_nil
  end

  it { should validate_presence_of(:week_start_date) }

  it { should belong_to(:staff) }

  describe '#public_id' do
    it 'is :weekly_exp_id' do
      StaffWeeklyExpense.new(:weekly_exp_id => '55').public_id.should == '55'
    end
  end

  describe "visible_expenses" do
    before(:each) do
      staff1 = FactoryGirl.create(:staff)
      staff2 = FactoryGirl.create(:staff)
      staff3 = FactoryGirl.create(:staff)

      @expense1 = staff1.staff_weekly_expenses.create(:week_start_date => (Date.today - 1.week).monday)
      @expense2 = staff2.staff_weekly_expenses.create(:week_start_date => (Date.today - 1.week).monday)
      @expense3 = staff3.staff_weekly_expenses.create(:week_start_date => Date.today.monday)

      role = Role.find_by_name(Role::STAFF_SUPERVISOR)
      role = FactoryGirl.create(:role, :name => Role::STAFF_SUPERVISOR) unless role

      @sup1 = FactoryGirl.create(:staff, :first_name => "Supervisor")
      @sup1.roles << role
      @sup1.employees = [staff1, staff2]
    end

    it "should return the staff weekly expense for given staff_ids only" do
      actaul_expenses = StaffWeeklyExpense.visible_expenses(@sup1.visible_employees.map(&:id))
      actaul_expenses.count.should == 2
      actaul_expenses.should include @expense1
      actaul_expenses.should include @expense2
    end

    it "should return all staff weekly expense if no staff_ids passed" do
      actaul_expenses = StaffWeeklyExpense.visible_expenses()
      actaul_expenses.count.should == 3
    end
  end

  describe "total" do
    before(:each) do
      @expense = Factory(:staff_weekly_expense)
    end

    describe "hours" do
      it "uses the weekly_expenses hours if set" do
        @expense.update_attribute(:hours, '25')
        @expense.total_hours.should == 25
      end

      it "gives total hours of management_tasks and data_collection_task" do
        @expense.management_tasks << FactoryGirl.create(:management_task, :hours => 12)
        @expense.data_collection_tasks << FactoryGirl.create(:data_collection_task, :hours => 15)
        @expense.total_hours.should == 27
      end

      it "gives total hours of management_tasks hours only if no data_collection_tasks associated with weekly_expenses" do
        @expense.management_tasks << FactoryGirl.create(:management_task, :hours => 20)
        @expense.total_hours.should == 20
      end

      it "gives total hours of data_collection_tasks hours only if no management_tasks associated with weekly_expenses" do
        @expense.data_collection_tasks << FactoryGirl.create(:data_collection_task, :hours => 18)
        @expense.total_hours.should == 18
      end

      it "uses 0.0 if there are no hours" do
        @expense.total_hours.should == 0.0
      end
    end

    describe "miles" do
      it "uses the weekly_expenses miles if set" do
        @expense.update_attribute(:miles, '25.78')
        @expense.total_miles.should == 25.78
      end

      it "gives total miles of management_tasks and data_collection_task" do
        @expense.management_tasks << FactoryGirl.create(:management_task, :miles => 12)
        @expense.data_collection_tasks << FactoryGirl.create(:data_collection_task, :miles => 15)
        @expense.total_miles.should == 27
      end

      it "gives total miles of management_tasks miles only if no data_collection_tasks associated with weekly_expenses" do
        @expense.management_tasks << FactoryGirl.create(:management_task, :miles => 20)
        @expense.total_miles.should == 20
      end

      it "gives total miles of data_collection_tasks miles only if no management_tasks associated with weekly_expenses" do
        @expense.data_collection_tasks << FactoryGirl.create(:data_collection_task, :miles => 18)
        @expense.total_miles.should == 18
      end

      it "uses 0.0 if there are no miles" do
        @expense.total_miles.should == 0.0
      end
    end

    describe "expenses" do
      it "uses the weekly_expenses expenses if set" do
        @expense.update_attribute(:expenses, '250')
        @expense.total_expenses.should == 250
      end

      it "gives total expenses of management_tasks and data_collection_task" do
        @expense.management_tasks << FactoryGirl.create(:management_task, :expenses => 200)
        @expense.data_collection_tasks << FactoryGirl.create(:data_collection_task, :expenses => 150)
        @expense.total_expenses.should == 350
      end

      it "gives total expenses of management_tasks expenses only if no data_collection_tasks associated with weekly_expenses" do
        @expense.management_tasks << FactoryGirl.create(:management_task, :expenses => 250)
        @expense.total_expenses.should == 250
      end

      it "gives total expenses of data_collection_tasks expenses only if no management_tasks associated with weekly_expenses" do
        @expense.data_collection_tasks << FactoryGirl.create(:data_collection_task, :expenses => 300)
        @expense.total_expenses.should == 300
      end

      it "uses 0.0 if there are no expenses" do
        @expense.total_expenses.should == 0.0
      end
    end

    describe "expenses" do
      it "gives total numbers of management_tasks and data_collection_tasks" do
        @expense.management_tasks << FactoryGirl.create(:management_task)
        @expense.management_tasks << FactoryGirl.create(:management_task)
        @expense.data_collection_tasks << FactoryGirl.create(:data_collection_task)
        @expense.total_tasks.should == 3
      end

      it "gives total numbers management_tasks only if no data_collection_tasks associated with weekly_expenses" do
        @expense.management_tasks << FactoryGirl.create(:management_task)
        @expense.total_tasks.should == 1
      end

      it "gives total numbers of data_collection_tasks only if no management_tasks associated with weekly_expenses" do
        @expense.data_collection_tasks << FactoryGirl.create(:data_collection_task)
        @expense.data_collection_tasks << FactoryGirl.create(:data_collection_task)
        @expense.total_tasks.should == 2
      end
    end
  end
end
