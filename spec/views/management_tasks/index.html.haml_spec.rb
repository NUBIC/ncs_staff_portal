require 'spec_helper'

describe "management_tasks/index.html.haml" do
  before(:each) do
    assign(:management_tasks, [
      stub_model(ManagementTask,
        :task_type_code => 1,
        :task_type_other => "Task Type Other",
        :task_hours => "9.99",
        :comment => "MyText"
      ),
      stub_model(ManagementTask,
        :task_type_code => 1,
        :task_type_other => "Task Type Other",
        :task_hours => "9.99",
        :comment => "MyText"
      )
    ])
  end

  it "renders a list of management_tasks" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Task Type Other".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
