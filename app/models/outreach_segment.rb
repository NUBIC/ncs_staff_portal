class OutreachSegment < ActiveRecord::Base
  belongs_to :outreach_event
  belongs_to :ncs_area
  validates_presence_of :ncs_area
end
