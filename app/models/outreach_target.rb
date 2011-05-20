class OutreachTarget < ActiveRecord::Base
  belongs_to :outreach_events
  belongs_to :target, :conditions => "list_name = 'OUTREACH_TARGET_CL1'", :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :target_code
end
