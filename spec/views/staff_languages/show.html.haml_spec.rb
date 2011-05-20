require 'spec_helper'

describe "staff_languages/show.html.haml" do
  before(:each) do
    @staff_language = assign(:staff_language, stub_model(StaffLanguage,
      :staff_id => 1,
      :lang_code => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
  end
end
