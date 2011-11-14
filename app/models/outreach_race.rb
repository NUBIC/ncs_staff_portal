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
#

class OutreachRace < ActiveRecord::Base
  belongs_to :outreach_event
  validates_presence_of :race
  belongs_to :race, :conditions => "list_name = 'RACE_CL3'", :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :race_code
  
  validates_with OtherEntryValidator, :entry => :race, :other_entry => :race_other
end
