class StaffLanguage < ActiveRecord::Base
  belongs_to :staff
  validates_presence_of:lang_code
end
