require 'spec_helper'

describe "StaffCertTrainings" do
  describe "GET /staff_cert_trainings" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get staff_cert_trainings_path
      response.status.should be(200)
    end
  end
end
