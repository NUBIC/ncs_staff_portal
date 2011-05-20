require "spec_helper"

describe StaffCertTrainingsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/staff_cert_trainings" }.should route_to(:controller => "staff_cert_trainings", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/staff_cert_trainings/new" }.should route_to(:controller => "staff_cert_trainings", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/staff_cert_trainings/1" }.should route_to(:controller => "staff_cert_trainings", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/staff_cert_trainings/1/edit" }.should route_to(:controller => "staff_cert_trainings", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/staff_cert_trainings" }.should route_to(:controller => "staff_cert_trainings", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/staff_cert_trainings/1" }.should route_to(:controller => "staff_cert_trainings", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/staff_cert_trainings/1" }.should route_to(:controller => "staff_cert_trainings", :action => "destroy", :id => "1")
    end

  end
end
