# == Schema Information
#
# Table name: outreach_races
#
#  id                :integer         not null, primary key
#  outreach_event_id :integer
#  race_code         :integer         not null
#  race_other        :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  outreach_race_id  :string(36)      not null
#  source_id         :string(36)
#

class OutreachRace < ActiveRecord::Base
  include MdesRecord::ActsAsMdesRecord
  strip_attributes
  acts_as_mdes_record :public_id => :outreach_race_id
  ncs_coded_attribute :race, 'RACE_CL3'
  belongs_to :outreach_event
  validates_presence_of :race
  
  validates_with OtherEntryValidator, :entry => :race, :other_entry => :race_other
end
