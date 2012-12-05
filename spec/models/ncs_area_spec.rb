# == Schema Information
#
# Table name: ncs_areas
#
#  id     :integer         not null, primary key
#  psu_id :string(255)     not null
#  name   :string(255)     not null
#

require 'spec_helper'

describe NcsArea do
  it "should create a new instance given valid attributes" do
    area = Factory(:ncs_area)
    area.should_not be_nil
  end

  it { should validate_presence_of(:psu_id) }

  it { should validate_presence_of(:name) }

  it "should require name to be unique per psu" do
    area = FactoryGirl.create(:ncs_area, :name => "testing")
    area1 = FactoryGirl.build(:ncs_area, :name => "testing")
    area1.save
    area1.should_not be_valid
  end

end
