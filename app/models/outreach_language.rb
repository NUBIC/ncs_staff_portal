class OutreachLanguage < ActiveRecord::Base
  belongs_to :outreach_event
  validates_presence_of :language
  belongs_to :language, :conditions => "list_name = 'LANGUAGE_CL2'", :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :language_code
end
