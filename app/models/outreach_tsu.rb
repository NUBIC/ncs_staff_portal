# == Schema Information
#
# Table name: outreach_tsus
#
#  id                :integer         not null, primary key
#  outreach_event_id :integer
#  ncs_tsu_id        :integer
#  created_at        :datetime
#  updated_at        :datetime
#

class OutreachTsu < ActiveRecord::Base
  belongs_to :outreach_event
  belongs_to :ncs_tsu
end
