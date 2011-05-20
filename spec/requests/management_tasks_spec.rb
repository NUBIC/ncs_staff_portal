require 'spec_helper'

describe "ManagementTasks" do
  describe "GET /management_tasks" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get management_tasks_path
      response.status.should be(200)
    end
  end
end
