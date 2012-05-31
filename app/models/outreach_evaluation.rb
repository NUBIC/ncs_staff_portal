# == Schema Information
#
# Table name: outreach_evaluations
#
#  id                     :integer         not null, primary key
#  outreach_event_id      :integer
#  evaluation_code        :integer         not null
#  evaluation_other       :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  outreach_event_eval_id :string(36)      not null
#

class OutreachEvaluation < ActiveRecord::Base
  include MdesRecord::ActsAsMdesRecord
  acts_as_mdes_record :public_id => :outreach_event_eval_id
  ncs_coded_attribute :evaluation, 'OUTREACH_EVAL_CL1'
  belongs_to :outreach_event
  validates_presence_of :evaluation
    
  validates_with OtherEntryValidator, :entry => :evaluation, :other_entry => :evaluation_other
end
