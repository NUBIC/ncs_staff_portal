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

class OutreachStaffMember < ActiveRecord::Base
  belongs_to :staff
  validates_presence_of :staff
  belongs_to :outreach_event
end
