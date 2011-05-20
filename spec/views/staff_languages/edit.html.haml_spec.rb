require 'spec_helper'

describe "staff_languages/edit.html.haml" do
  before(:each) do
    @staff_language = assign(:staff_language, stub_model(StaffLanguage,
      :staff_id => 1,
      :lang_code => 1
    ))
  end

  it "renders the edit staff_language form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => staff_languages_path(@staff_language), :method => "post" do
      assert_select "input#staff_language_staff_id", :name => "staff_language[staff_id]"
      assert_select "input#staff_language_lang_code", :name => "staff_language[lang_code]"
    end
  end
end
