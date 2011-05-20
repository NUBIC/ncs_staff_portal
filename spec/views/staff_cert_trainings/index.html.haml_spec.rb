require 'spec_helper'

describe "staff_cert_trainings/index.html.haml" do
  before(:each) do
    assign(:staff_cert_trainings, [
      stub_model(StaffCertTraining,
        :certificate_type_code => 1,
        :complete_code => 1,
        :cert_date => "Cert Date",
        :background_check_code => 1,
        :frequency => "Frequency"
      ),
      stub_model(StaffCertTraining,
        :certificate_type_code => 1,
        :complete_code => 1,
        :cert_date => "Cert Date",
        :background_check_code => 1,
        :frequency => "Frequency"
      )
    ])
  end

  it "renders a list of staff_cert_trainings" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Cert Date".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Frequency".to_s, :count => 2
  end
end
