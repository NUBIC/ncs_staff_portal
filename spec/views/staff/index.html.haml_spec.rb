require 'spec_helper'

describe "staff/index.html.haml" do
  before(:each) do
    assign(:staff, [
      stub_model(Staff,
        :name => "Name",
        :email => "Email",
        :netid => "Netid",
        :study_center => 1,
        :type_code => 1
      ),
      stub_model(Staff,
        :name => "Name",
        :email => "Email",
        :netid => "Netid",
        :study_center => 1,
        :type_code => 1
      )
    ])
  end

  it "renders a list of staff" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Email".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Netid".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
