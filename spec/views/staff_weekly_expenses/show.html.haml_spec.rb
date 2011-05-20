require 'spec_helper'

describe "staff_weekly_expenses/show.html.haml" do
  before(:each) do
    @staff_weekly_expense = assign(:staff_weekly_expense, stub_model(StaffWeeklyExpense,
      :staff_pay => "9.99",
      :staff_hours => "9.99",
      :staff_expenses => "9.99",
      :staff_miles => "9.99",
      :comment => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/9.99/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/9.99/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/9.99/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/9.99/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/MyText/)
  end
end
