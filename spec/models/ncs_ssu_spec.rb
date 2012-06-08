# == Schema Information
#
# Table name: ncs_ssus
#
#  id         :integer         not null, primary key
#  psu_id     :string(36)      not null
#  ssu_id     :string(36)      not null
#  ssu_name   :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe NcsSsu do
    it "should create a new instance given valid attributes" do
      ssu = Factory(:ncs_ssu)
      ssu.should_not be_nil
    end

    it { should validate_presence_of(:psu_id) }

    it { should validate_presence_of(:ssu_id) }
end
