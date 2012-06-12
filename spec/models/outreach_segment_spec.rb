# == Schema Information
#
# Table name: outreach_segments
#
#  id                :integer         not null, primary key
#  outreach_event_id :integer
#  created_at        :datetime
#  updated_at        :datetime
#  ncs_ssu_id        :integer
#  ncs_tsu_id        :integer
#

require 'spec_helper'

describe OutreachSegment do
  it "should create a new instance given valid attributes" do
    segment = Factory(:outreach_segment)
    segment.should_not be_nil
  end
  
  it { should belong_to(:ncs_ssu) }
end
