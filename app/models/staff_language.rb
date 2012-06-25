# == Schema Information
#
# Table name: staff_languages
#
#  id                :integer         not null, primary key
#  staff_id          :integer
#  lang_code         :integer         not null
#  lang_other        :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  staff_language_id :string(36)      not null
#

class StaffLanguage < ActiveRecord::Base
  include MdesRecord::ActsAsMdesRecord
  belongs_to :staff
  # validates_presence_of :lang
  ncs_coded_attribute :lang, 'LANGUAGE_CL2'

  acts_as_mdes_record :public_id => :staff_language_id

  validates_with OtherEntryValidator, :entry => :lang, :other_entry => :lang_other

  self.include_root_in_json = false
  def as_json(options={})
    { "name" => self.lang.display_text }
  end
end
