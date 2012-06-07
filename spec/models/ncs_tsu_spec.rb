# == Schema Information
#
# Table name: ncs_tsus
#
#  id         :integer         not null, primary key
#  psu_id     :string(36)      not null
#  tsu_id     :string(36)      not null
#  tsu_name   :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe NcsTsu do
  it "should create a new instance given valid attributes" do
    ssu = Factory(:ncs_tsu)
    ssu.should_not be_nil
  end

  it { should validate_presence_of(:psu_id) }

  it { should validate_presence_of(:tsu_id) }
end
