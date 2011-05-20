require 'spec_helper'

describe StaffCertTrainingsController do

  def mock_staff_cert_training(stubs={})
    @mock_staff_cert_training ||= mock_model(StaffCertTraining, stubs).as_null_object
    @mock_staff ||= mock_model(Staff, stubs).as_null_object
  end
  
  def mock_staff(stubs={})
    @mock_staff ||= mock_model(Staff, stubs).as_null_object
  end
  

  describe "GET new" do
    it "assigns a new staff_cert_training as @staff_cert_training" do
      Staff.stub(:find).with("1") { mock_staff }
      mock_staff.staff_cert_training.stub(:new) { mock_staff_cert_training }
      get :new, :staff_id => "1"
      assigns(:staff_cert_training).should be(mock_staff_cert_training)
    end
  end

  describe "GET edit" do
    it "assigns the requested staff_cert_training as @staff_cert_training" do
      Staff.stub(:find).with("1") { mock_staff }
      mock_staff.staff_cert_training.stub(:find).with("37") { mock_staff_cert_training }
      get :edit, :id => "37", :staff_id => "1"
      assigns(:staff_cert_training).should be(mock_staff_cert_training)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "assigns a newly created staff_cert_training as @staff_cert_training" do
        Staff.stub(:find).with("1") { mock_staff }
        mock_staff.staff_cert_training.stub(:new).with({'these' => 'params'}) { mock_staff_cert_training(:save => true) }
        post :create, :staff_cert_training => {'these' => 'params'}, :staff_id => "1"
        assigns(:staff_cert_training).should be(mock_staff_cert_training)
      end

      it "redirects to the trainings page" do
        Staff.stub(:find).with("1") { mock_staff }
        mock_staff.staff_cert_training.stub(:new) { mock_staff_cert_training(:save => true) }
        post :create, :staff_cert_training => {}, :staff_id => "1"
        response.should redirect_to(new_staff_staff_cert_training_path(mock_staff))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved staff_cert_training as @staff_cert_training" do
        Staff.stub(:find).with("1") { mock_staff }
        mock_staff.staff_cert_training.stub(:new).with({'these' => 'params'}) { mock_staff_cert_training(:save => false) }
        post :create, :staff_cert_training => {'these' => 'params'}, :staff_id => "1"
        assigns(:staff_cert_training).should be(mock_staff_cert_training)
      end

      it "redirects to the trainings page" do
        Staff.stub(:find).with("1") { mock_staff }
        mock_staff.staff_cert_training.stub(:new) { mock_staff_cert_training(:save => false) }
        post :create, :staff_cert_training => {}, :staff_id => "1"
        response.should redirect_to(new_staff_staff_cert_training_path(mock_staff))
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested staff_cert_training" do
        Staff.stub(:find).with("1") { mock_staff }
        mock_staff.staff_cert_training.stub(:find).with("37") { mock_staff_cert_training }
        mock_staff_cert_training.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :staff_cert_training => {'these' => 'params'}, :staff_id => "1"
      end

      it "assigns the requested staff_cert_training as @staff_cert_training" do
        Staff.stub(:find).with("1") { mock_staff }
        mock_staff.staff_cert_training.stub(:find) { mock_staff_cert_training(:update_attributes => true) }
        put :update, :id => "1", :staff_id => "1"
        assigns(:staff_cert_training).should be(mock_staff_cert_training)
      end

      it "redirects to the trainings page" do
        Staff.stub(:find).with("1") { mock_staff }
        mock_staff.staff_cert_training.stub(:find) { mock_staff_cert_training(:update_attributes => true) }
        put :update, :id => "1", :staff_id => "1"
        response.should redirect_to(new_staff_staff_cert_training_path(mock_staff))
      end
    end

    describe "with invalid params" do
      it "assigns the staff_cert_training as @staff_cert_training" do
        Staff.stub(:find).with("1") { mock_staff }
        mock_staff.staff_cert_training.stub(:find) { mock_staff_cert_training(:update_attributes => false) }
        put :update, :id => "1", :staff_id => "1"
        assigns(:staff_cert_training).should be(mock_staff_cert_training)
      end

      it "redirects to the trainings page" do
        Staff.stub(:find).with("1") { mock_staff }
        mock_staff.staff_cert_training.stub(:find) { mock_staff_cert_training(:update_attributes => false) }
        put :update, :id => "1", :staff_id => "1"
        response.should redirect_to(new_staff_staff_cert_training_path(mock_staff))
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested staff_cert_training" do
      Staff.stub(:find).with("1") { mock_staff }
      mock_staff.staff_cert_training.stub(:find).with("37") { mock_staff_cert_training }
      mock_staff_cert_training.should_receive(:destroy)
      delete :destroy, :id => "37", :staff_id => "1"
    end
  end

end
