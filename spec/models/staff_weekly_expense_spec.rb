require 'spec_helper'

describe StaffWeeklyExpense do
  it "should create a new instance given valid attributes" do
    expense = Factory(:staff_weekly_expense)
    expense.should_not be_nil
  end
  
  it { should validate_presence_of(:week_start_date) }
  
  it { should belong_to(:staff) }
  
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
end
