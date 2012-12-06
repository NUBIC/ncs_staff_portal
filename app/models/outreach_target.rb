# == Schema Information
#
# Table name: outreach_targets
#
#  id                 :integer         not null, primary key
#  outreach_event_id  :integer
#  target_code        :integer         not null
#  target_other       :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  outreach_target_id :string(36)      not null
#  source_id          :string(36)
#

class OutreachTarget < ActiveRecord::Base
  include MdesRecord::ActsAsMdesRecord
  strip_attributes
  acts_as_mdes_record :public_id => :outreach_target_id
  ncs_coded_attribute :target, 'OUTREACH_TARGET_CL1'
  belongs_to :outreach_event
  validates_presence_of :target

  validates_with OtherEntryValidator, :entry => :target, :other_entry => :target_other
end
