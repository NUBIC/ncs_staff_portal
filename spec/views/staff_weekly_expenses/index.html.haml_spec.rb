require 'spec_helper'

describe "staff_weekly_expenses/index.html.haml" do
  before(:each) do
    assign(:staff_weekly_expenses, [
      stub_model(StaffWeeklyExpense,
        :staff_pay => "9.99",
        :staff_hours => "9.99",
        :staff_expenses => "9.99",
        :staff_miles => "9.99",
        :comment => "MyText"
      ),
      stub_model(StaffWeeklyExpense,
        :staff_pay => "9.99",
        :staff_hours => "9.99",
        :staff_expenses => "9.99",
        :staff_miles => "9.99",
        :comment => "MyText"
      )
    ])
  end

  it "renders a list of staff_weekly_expenses" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
