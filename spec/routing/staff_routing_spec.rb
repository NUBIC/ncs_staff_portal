require "spec_helper"

describe StaffController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/staff" }.should route_to(:controller => "staff", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/staff/new" }.should route_to(:controller => "staff", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/staff/1" }.should route_to(:controller => "staff", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/staff/1/edit" }.should route_to(:controller => "staff", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/staff" }.should route_to(:controller => "staff", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/staff/1" }.should route_to(:controller => "staff", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/staff/1" }.should route_to(:controller => "staff", :action => "destroy", :id => "1")
    end

  end
end
