# == Schema Information
#
# Table name: outreach_segments
#
#  id                :integer         not null, primary key
#  outreach_event_id :integer
#  ncs_area_id       :integer
#  created_at        :datetime
#  updated_at        :datetime
#

class OutreachSegment < ActiveRecord::Base
  belongs_to :outreach_event
  belongs_to :ncs_area
  validates_presence_of :ncs_area
end
