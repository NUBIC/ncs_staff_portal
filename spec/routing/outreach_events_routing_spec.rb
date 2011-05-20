require "spec_helper"

describe OutreachEventsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/outreach_events" }.should route_to(:controller => "outreach_events", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/outreach_events/new" }.should route_to(:controller => "outreach_events", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/outreach_events/1" }.should route_to(:controller => "outreach_events", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/outreach_events/1/edit" }.should route_to(:controller => "outreach_events", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/outreach_events" }.should route_to(:controller => "outreach_events", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/outreach_events/1" }.should route_to(:controller => "outreach_events", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/outreach_events/1" }.should route_to(:controller => "outreach_events", :action => "destroy", :id => "1")
    end

  end
end
