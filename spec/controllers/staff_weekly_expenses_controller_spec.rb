require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by the Rails when you ran the scaffold generator.

describe StaffWeeklyExpensesController do
  before(:each) do
    login_as("superuser")
  end
  def mock_staff_weekly_expense(stubs={})
    @mock_staff_weekly_expense ||= mock_model(StaffWeeklyExpense, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all staff_weekly_expenses as @staff_weekly_expenses" do
      StaffWeeklyExpense.stub(:all) { [mock_staff_weekly_expense] }
      get :index
      assigns(:staff_weekly_expenses).should eq([mock_staff_weekly_expense])
    end
  end

  describe "GET show" do
    it "assigns the requested staff_weekly_expense as @staff_weekly_expense" do
      StaffWeeklyExpense.stub(:find).with("37") { mock_staff_weekly_expense }
      get :show, :id => "37"
      assigns(:staff_weekly_expense).should be(mock_staff_weekly_expense)
    end
  end

  describe "GET new" do
    it "assigns a new staff_weekly_expense as @staff_weekly_expense" do
      StaffWeeklyExpense.stub(:new) { mock_staff_weekly_expense }
      get :new
      assigns(:staff_weekly_expense).should be(mock_staff_weekly_expense)
    end
  end

  describe "GET edit" do
    it "assigns the requested staff_weekly_expense as @staff_weekly_expense" do
      StaffWeeklyExpense.stub(:find).with("37") { mock_staff_weekly_expense }
      get :edit, :id => "37"
      assigns(:staff_weekly_expense).should be(mock_staff_weekly_expense)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "assigns a newly created staff_weekly_expense as @staff_weekly_expense" do
        StaffWeeklyExpense.stub(:new).with({'these' => 'params'}) { mock_staff_weekly_expense(:save => true) }
        post :create, :staff_weekly_expense => {'these' => 'params'}
        assigns(:staff_weekly_expense).should be(mock_staff_weekly_expense)
      end

      it "redirects to the created staff_weekly_expense" do
        StaffWeeklyExpense.stub(:new) { mock_staff_weekly_expense(:save => true) }
        post :create, :staff_weekly_expense => {}
        response.should redirect_to(staff_weekly_expense_url(mock_staff_weekly_expense))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved staff_weekly_expense as @staff_weekly_expense" do
        StaffWeeklyExpense.stub(:new).with({'these' => 'params'}) { mock_staff_weekly_expense(:save => false) }
        post :create, :staff_weekly_expense => {'these' => 'params'}
        assigns(:staff_weekly_expense).should be(mock_staff_weekly_expense)
      end

      it "re-renders the 'new' template" do
        StaffWeeklyExpense.stub(:new) { mock_staff_weekly_expense(:save => false) }
        post :create, :staff_weekly_expense => {}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested staff_weekly_expense" do
        StaffWeeklyExpense.stub(:find).with("37") { mock_staff_weekly_expense }
        mock_staff_weekly_expense.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :staff_weekly_expense => {'these' => 'params'}
      end

      it "assigns the requested staff_weekly_expense as @staff_weekly_expense" do
        StaffWeeklyExpense.stub(:find) { mock_staff_weekly_expense(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:staff_weekly_expense).should be(mock_staff_weekly_expense)
      end

      it "redirects to the staff_weekly_expense" do
        StaffWeeklyExpense.stub(:find) { mock_staff_weekly_expense(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(staff_weekly_expense_url(mock_staff_weekly_expense))
      end
    end

    describe "with invalid params" do
      it "assigns the staff_weekly_expense as @staff_weekly_expense" do
        StaffWeeklyExpense.stub(:find) { mock_staff_weekly_expense(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:staff_weekly_expense).should be(mock_staff_weekly_expense)
      end

      it "re-renders the 'edit' template" do
        StaffWeeklyExpense.stub(:find) { mock_staff_weekly_expense(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested staff_weekly_expense" do
      StaffWeeklyExpense.stub(:find).with("37") { mock_staff_weekly_expense }
      mock_staff_weekly_expense.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the staff_weekly_expenses list" do
      StaffWeeklyExpense.stub(:find) { mock_staff_weekly_expense }
      delete :destroy, :id => "1"
      response.should redirect_to(staff_weekly_expenses_url)
    end
  end

end
