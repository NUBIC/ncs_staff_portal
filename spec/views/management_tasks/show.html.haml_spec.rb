require 'spec_helper'

describe "management_tasks/show.html.haml" do
  before(:each) do
    @management_task = assign(:management_task, stub_model(ManagementTask,
      :task_type_code => 1,
      :task_type_other => "Task Type Other",
      :task_hours => "9.99",
      :comment => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Task Type Other/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/9.99/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/MyText/)
  end
end
