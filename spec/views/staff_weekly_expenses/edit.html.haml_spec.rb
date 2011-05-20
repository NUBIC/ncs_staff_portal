require 'spec_helper'

describe "staff_weekly_expenses/edit.html.haml" do
  before(:each) do
    @staff_weekly_expense = assign(:staff_weekly_expense, stub_model(StaffWeeklyExpense,
      :staff_pay => "9.99",
      :staff_hours => "9.99",
      :staff_expenses => "9.99",
      :staff_miles => "9.99",
      :comment => "MyText"
    ))
  end

  it "renders the edit staff_weekly_expense form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => staff_weekly_expenses_path(@staff_weekly_expense), :method => "post" do
      assert_select "input#staff_weekly_expense_staff_pay", :name => "staff_weekly_expense[staff_pay]"
      assert_select "input#staff_weekly_expense_staff_hours", :name => "staff_weekly_expense[staff_hours]"
      assert_select "input#staff_weekly_expense_staff_expenses", :name => "staff_weekly_expense[staff_expenses]"
      assert_select "input#staff_weekly_expense_staff_miles", :name => "staff_weekly_expense[staff_miles]"
      assert_select "textarea#staff_weekly_expense_comment", :name => "staff_weekly_expense[comment]"
    end
  end
end
