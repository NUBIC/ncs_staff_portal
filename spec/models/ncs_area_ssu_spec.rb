require 'spec_helper'

describe NcsAreaSsu do
  it "should create a new instance given valid attributes" do
    ssu = Factory(:ncs_area_ssu)
    ssu.should_not be_nil
  end
  
  it { should validate_presence_of(:ssu_id) }
  
  it { should validate_presence_of(:ncs_area_id) }
  
end
