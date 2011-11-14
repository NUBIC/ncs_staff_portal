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
#

class OutreachLanguage < ActiveRecord::Base
  belongs_to :outreach_event
  validates_presence_of :language
  belongs_to :language, :conditions => "list_name = 'LANGUAGE_CL2'", :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :language_code
  
  validates_with OtherEntryValidator, :entry => :language, :other_entry => :language_other
  
  # validate :other_value_check(:language, :language_other)
  # def language_other_value
  #    if !language.blank? && language.display_text.match(/\bother\b/i)
  #      if language_other.blank?
  #         errors.add :language_other, "can't be blank. Please enter any other language."
  #      end
  #    elsif language_other.blank?
  #       self.language_other = nil
  #    end
  #  end
end
