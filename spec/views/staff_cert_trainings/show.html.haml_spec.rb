require 'spec_helper'

describe "staff_cert_trainings/show.html.haml" do
  before(:each) do
    @staff_cert_training = assign(:staff_cert_training, stub_model(StaffCertTraining,
      :certificate_type_code => 1,
      :complete_code => 1,
      :cert_date => "Cert Date",
      :background_check_code => 1,
      :frequency => "Frequency"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Cert Date/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Frequency/)
  end
end
