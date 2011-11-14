# == Schema Information
#
# Table name: outreach_staff_members
#
#  id                :integer         not null, primary key
#  staff_id          :integer
#  outreach_event_id :integer
#  created_at        :datetime
#  updated_at        :datetime
#

require 'spec_helper'

describe OutreachStaffMember do
  it "should create a new instance given valid attributes" do
    member = Factory(:outreach_staff_member)
    member.should_not be_nil
  end
  
  it { should belong_to(:staff) }
  
  it { should validate_presence_of(:staff) }
end
