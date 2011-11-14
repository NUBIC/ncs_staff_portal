# == Schema Information
#
# Table name: ncs_area_ssus
#
#  id          :integer         not null, primary key
#  ncs_area_id :integer
#  ssu_id      :string(255)     not null
#  ssu_name    :string(255)
#

require 'spec_helper'

describe NcsAreaSsu do
  it "should create a new instance given valid attributes" do
    ssu = Factory(:ncs_area_ssu)
    ssu.should_not be_nil
  end
  
  it { should validate_presence_of(:ssu_id) }
  
  it { should validate_presence_of(:ncs_area_id) }
  
end
