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

class OutreachSegment < ActiveRecord::Base
  belongs_to :outreach_event
  belongs_to :ncs_ssu
end
