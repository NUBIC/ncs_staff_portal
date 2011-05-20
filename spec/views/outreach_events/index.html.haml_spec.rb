require 'spec_helper'

describe "outreach_events/index.html.haml" do
  before(:each) do
    assign(:outreach_events, [
      stub_model(OutreachEvent,
        :mode_code => 1,
        :mode_other => "Mode Other",
        :outreach_type_code => 1,
        :outreach_type_other => "Outreach Type Other",
        :tailored_code => 1,
        :language_specific_code => 1,
        :language_code => 1,
        :language_other => "Language Other",
        :race_specific_code => 1,
        :culture_specific_code => 1,
        :culture_code => 1,
        :culture_other => "Culture Other",
        :quantity => 1,
        :cost => "9.99",
        :no_of_staff => 1,
        :evaluation_result_code => 1
      ),
      stub_model(OutreachEvent,
        :mode_code => 1,
        :mode_other => "Mode Other",
        :outreach_type_code => 1,
        :outreach_type_other => "Outreach Type Other",
        :tailored_code => 1,
        :language_specific_code => 1,
        :language_code => 1,
        :language_other => "Language Other",
        :race_specific_code => 1,
        :culture_specific_code => 1,
        :culture_code => 1,
        :culture_other => "Culture Other",
        :quantity => 1,
        :cost => "9.99",
        :no_of_staff => 1,
        :evaluation_result_code => 1
      )
    ])
  end

  it "renders a list of outreach_events" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Mode Other".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Outreach Type Other".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Language Other".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Culture Other".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
