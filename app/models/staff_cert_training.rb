class StaffCertTraining < ActiveRecord::Base
  validates_presence_of :certificate_type_code
  ATTRIBUTE_MAPPING = { 
    :certificate_type_code => "CERTIFICATE_TYPE_CL1",
    :complete_code => "CONFIRM_TYPE_CL2",
    :background_check_code => "BACKGROUND_CHCK_LVL_CL1"
    }
  ATTRIBUTE_MAPPING.each do |key, value|
    rel_name = key.to_s.gsub('_code', '')
    belongs_to rel_name, :conditions => "list_name = '#{value}'", :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => key
  end
end
