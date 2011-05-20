require 'spec_helper'

describe "staff_cert_trainings/edit.html.haml" do
  before(:each) do
    @staff_cert_training = assign(:staff_cert_training, stub_model(StaffCertTraining,
      :certificate_type_code => 1,
      :complete_code => 1,
      :cert_date => "MyString",
      :background_check_code => 1,
      :frequency => "MyString"
    ))
  end

  it "renders the edit staff_cert_training form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => staff_cert_trainings_path(@staff_cert_training), :method => "post" do
      assert_select "input#staff_cert_training_certificate_type_code", :name => "staff_cert_training[certificate_type_code]"
      assert_select "input#staff_cert_training_complete_code", :name => "staff_cert_training[complete_code]"
      assert_select "input#staff_cert_training_cert_date", :name => "staff_cert_training[cert_date]"
      assert_select "input#staff_cert_training_background_check_code", :name => "staff_cert_training[background_check_code]"
      assert_select "input#staff_cert_training_frequency", :name => "staff_cert_training[frequency]"
    end
  end
end
