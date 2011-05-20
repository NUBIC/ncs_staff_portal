require 'spec_helper'

describe "staff_languages/index.html.haml" do
  before(:each) do
    assign(:staff_languages, [
      stub_model(StaffLanguage,
        :staff_id => 1,
        :lang_code => 1
      ),
      stub_model(StaffLanguage,
        :staff_id => 1,
        :lang_code => 1
      )
    ])
  end

  it "renders a list of staff_languages" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
