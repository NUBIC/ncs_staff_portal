# == Schema Information
#
# Table name: outreach_languages
#
#  id                :integer         not null, primary key
#  outreach_event_id :integer
#  language_code     :integer         not null
#  language_other    :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  outreach_lang2_id :string(36)      not null
#

class OutreachLanguage < ActiveRecord::Base
  include MdesRecord::ActsAsMdesRecord
  acts_as_mdes_record :public_id => :outreach_lang2_id
  ncs_coded_attribute :language, 'LANGUAGE_CL2'
  belongs_to :outreach_event
  validates_presence_of :language
  
  validates_with OtherEntryValidator, :entry => :language, :other_entry => :language_other
end
