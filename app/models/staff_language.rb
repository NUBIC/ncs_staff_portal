class StaffLanguage < ActiveRecord::Base
  belongs_to :staff
  validates_presence_of:lang_code
  belongs_to :lang, :conditions => "list_name = 'LANGUAGE_CL2'", :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :lang_code
end
