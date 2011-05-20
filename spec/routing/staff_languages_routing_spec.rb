require "spec_helper"

describe StaffLanguagesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/staff_languages" }.should route_to(:controller => "staff_languages", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/staff_languages/new" }.should route_to(:controller => "staff_languages", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/staff_languages/1" }.should route_to(:controller => "staff_languages", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/staff_languages/1/edit" }.should route_to(:controller => "staff_languages", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/staff_languages" }.should route_to(:controller => "staff_languages", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/staff_languages/1" }.should route_to(:controller => "staff_languages", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/staff_languages/1" }.should route_to(:controller => "staff_languages", :action => "destroy", :id => "1")
    end

  end
end
