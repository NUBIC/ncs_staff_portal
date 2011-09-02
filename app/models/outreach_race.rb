class OutreachRace < ActiveRecord::Base
  belongs_to :outreach_event
  validates_presence_of :race
  belongs_to :race, :conditions => "list_name = 'RACE_CL3'", :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :race_code
  
  validates_with OtherEntryValidator, :entry => :race, :other_entry => :race_other
end
