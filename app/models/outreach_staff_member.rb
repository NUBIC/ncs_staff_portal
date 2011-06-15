class OutreachStaffMember < ActiveRecord::Base
  belongs_to :staff
  validates_presence_of :staff
  belongs_to :outreach_events
end
