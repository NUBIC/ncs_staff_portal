require "spec_helper"

describe ManagementTasksController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/management_tasks" }.should route_to(:controller => "management_tasks", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/management_tasks/new" }.should route_to(:controller => "management_tasks", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/management_tasks/1" }.should route_to(:controller => "management_tasks", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/management_tasks/1/edit" }.should route_to(:controller => "management_tasks", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/management_tasks" }.should route_to(:controller => "management_tasks", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/management_tasks/1" }.should route_to(:controller => "management_tasks", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/management_tasks/1" }.should route_to(:controller => "management_tasks", :action => "destroy", :id => "1")
    end

  end
end
