# == Schema Information
#
# Table name: outreach_targets
#
#  id                :integer         not null, primary key
#  outreach_event_id :integer
#  target_code       :integer         not null
#  target_other      :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#

class OutreachTarget < ActiveRecord::Base
  belongs_to :outreach_event
  validates_presence_of :target
  belongs_to :target, :conditions => "list_name = 'OUTREACH_TARGET_CL1'", :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :target_code
  
  validates_with OtherEntryValidator, :entry => :target, :other_entry => :target_other
end
