# == Schema Information
#
# Table name: staff_languages
#
#  id         :integer         not null, primary key
#  staff_id   :integer
#  lang_code  :integer         not null
#  lang_other :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class StaffLanguage < ActiveRecord::Base
  belongs_to :staff
  validates_presence_of :lang
  belongs_to :lang, :conditions => "list_name = 'LANGUAGE_CL2'", :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :lang_code

  validates_with OtherEntryValidator, :entry => :lang, :other_entry => :lang_other

  self.include_root_in_json = false
  def as_json(options={})
    { "name" => self.lang.display_text }
  end
end
