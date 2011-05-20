require 'spec_helper'

describe "StaffLanguages" do
  describe "GET /staff_languages" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get staff_languages_path
      response.status.should be(200)
    end
  end
end
