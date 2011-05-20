class OutreachStaffMember < ActiveRecord::Base
  belongs_to :staff
  belongs_to :outreach_events
end
