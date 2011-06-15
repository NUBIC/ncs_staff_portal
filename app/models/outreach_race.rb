class OutreachRace < ActiveRecord::Base
  belongs_to :outreach_event
  belongs_to :race, :conditions => "list_name = 'RACE_CL3'", :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :race_code
end
