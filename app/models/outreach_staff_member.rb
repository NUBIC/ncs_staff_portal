# == Schema Information
#
# Table name: outreach_staff_members
#
#  id                      :integer          not null, primary key
#  staff_id                :integer
#  outreach_event_id       :integer
#  created_at              :datetime
#  updated_at              :datetime
#  outreach_event_staff_id :string(36)       not null
#  source_id               :string(36)
#

class OutreachStaffMember < ActiveRecord::Base
  acts_as_mdes_record :public_id => :outreach_event_staff_id
  belongs_to :staff
  validates_presence_of :staff
  belongs_to :outreach_event
end
