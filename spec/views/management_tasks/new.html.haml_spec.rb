require 'spec_helper'

describe "management_tasks/new.html.haml" do
  before(:each) do
    assign(:management_task, stub_model(ManagementTask,
      :task_type_code => 1,
      :task_type_other => "MyString",
      :task_hours => "9.99",
      :comment => "MyText"
    ).as_new_record)
  end

  it "renders new management_task form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => management_tasks_path, :method => "post" do
      assert_select "input#management_task_task_type_code", :name => "management_task[task_type_code]"
      assert_select "input#management_task_task_type_other", :name => "management_task[task_type_other]"
      assert_select "input#management_task_task_hours", :name => "management_task[task_hours]"
      assert_select "textarea#management_task_comment", :name => "management_task[comment]"
    end
  end
end
