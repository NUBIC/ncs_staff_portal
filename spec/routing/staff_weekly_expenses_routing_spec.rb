require "spec_helper"

describe StaffWeeklyExpensesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/staff_weekly_expenses" }.should route_to(:controller => "staff_weekly_expenses", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/staff_weekly_expenses/new" }.should route_to(:controller => "staff_weekly_expenses", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/staff_weekly_expenses/1" }.should route_to(:controller => "staff_weekly_expenses", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/staff_weekly_expenses/1/edit" }.should route_to(:controller => "staff_weekly_expenses", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/staff_weekly_expenses" }.should route_to(:controller => "staff_weekly_expenses", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/staff_weekly_expenses/1" }.should route_to(:controller => "staff_weekly_expenses", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/staff_weekly_expenses/1" }.should route_to(:controller => "staff_weekly_expenses", :action => "destroy", :id => "1")
    end

  end
end
