require 'spec_helper'

describe "staff_languages/new.html.haml" do
  before(:each) do
    assign(:staff_language, stub_model(StaffLanguage,
      :staff_id => 1,
      :lang_code => 1
    ).as_new_record)
  end

  it "renders new staff_language form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => staff_languages_path, :method => "post" do
      assert_select "input#staff_language_staff_id", :name => "staff_language[staff_id]"
      assert_select "input#staff_language_lang_code", :name => "staff_language[lang_code]"
    end
  end
end
