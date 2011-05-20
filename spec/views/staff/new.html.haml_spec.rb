require 'spec_helper'

describe "staff/new.html.haml" do
  before(:each) do
    assign(:staff, stub_model(Staff,
      :name => "MyString",
      :email => "MyString",
      :netid => "MyString",
      :study_center => 1,
      :type_code => 1
    ).as_new_record)
  end

  it "renders new staff form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => staff_index_path, :method => "post" do
      assert_select "input#staff_name", :name => "staff[name]"
      assert_select "input#staff_email", :name => "staff[email]"
      assert_select "input#staff_netid", :name => "staff[netid]"
      assert_select "input#staff_study_center", :name => "staff[study_center]"
      assert_select "input#staff_type_code", :name => "staff[type_code]"
    end
  end
end
