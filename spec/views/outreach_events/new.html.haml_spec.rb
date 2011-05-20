require 'spec_helper'

describe "outreach_events/new.html.haml" do
  before(:each) do
    assign(:outreach_event, stub_model(OutreachEvent,
      :mode_code => 1,
      :mode_other => "MyString",
      :outreach_type_code => 1,
      :outreach_type_other => "MyString",
      :tailored_code => 1,
      :language_specific_code => 1,
      :language_code => 1,
      :language_other => "MyString",
      :race_specific_code => 1,
      :culture_specific_code => 1,
      :culture_code => 1,
      :culture_other => "MyString",
      :quantity => 1,
      :cost => "9.99",
      :no_of_staff => 1,
      :evaluation_result_code => 1
    ).as_new_record)
  end

  it "renders new outreach_event form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => outreach_events_path, :method => "post" do
      assert_select "input#outreach_event_mode_code", :name => "outreach_event[mode_code]"
      assert_select "input#outreach_event_mode_other", :name => "outreach_event[mode_other]"
      assert_select "input#outreach_event_outreach_type_code", :name => "outreach_event[outreach_type_code]"
      assert_select "input#outreach_event_outreach_type_other", :name => "outreach_event[outreach_type_other]"
      assert_select "input#outreach_event_tailored_code", :name => "outreach_event[tailored_code]"
      assert_select "input#outreach_event_language_specific_code", :name => "outreach_event[language_specific_code]"
      assert_select "input#outreach_event_language_code", :name => "outreach_event[language_code]"
      assert_select "input#outreach_event_language_other", :name => "outreach_event[language_other]"
      assert_select "input#outreach_event_race_specific_code", :name => "outreach_event[race_specific_code]"
      assert_select "input#outreach_event_culture_specific_code", :name => "outreach_event[culture_specific_code]"
      assert_select "input#outreach_event_culture_code", :name => "outreach_event[culture_code]"
      assert_select "input#outreach_event_culture_other", :name => "outreach_event[culture_other]"
      assert_select "input#outreach_event_quantity", :name => "outreach_event[quantity]"
      assert_select "input#outreach_event_cost", :name => "outreach_event[cost]"
      assert_select "input#outreach_event_no_of_staff", :name => "outreach_event[no_of_staff]"
      assert_select "input#outreach_event_evaluation_result_code", :name => "outreach_event[evaluation_result_code]"
    end
  end
end
