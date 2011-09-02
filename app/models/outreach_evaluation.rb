class OutreachEvaluation < ActiveRecord::Base
  belongs_to :outreach_events
  validates_presence_of :evaluation
  belongs_to :evaluation, :conditions => "list_name = 'OUTREACH_EVAL_CL1'", :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :evaluation_code
  
  validates_with OtherEntryValidator, :entry => :evaluation, :other_entry => :evaluation_other
end
