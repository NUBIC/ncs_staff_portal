class StaffCertTraining < ActiveRecord::Base
  validates_presence_of :certificate_type
  belongs_to :staff
  validates_date :expiration_date, :allow_blank => true
  validate :valid_cert_date
  
  def valid_cert_date
    if !(self.cert_date == "96/96/9666" || self.cert_date == "97/97/9777")
      validates_date :cert_date, :allow_blank => true
    end
  end
  ATTRIBUTE_MAPPING = { 
    :certificate_type_code => "CERTIFICATE_TYPE_CL1",
    :complete_code => "CONFIRM_TYPE_CL2",
    :background_check_code => "BACKGROUND_CHCK_LVL_CL1"
    }
    
  ATTRIBUTE_MAPPING.each do |key, value|
    rel_name = key.to_s.gsub('_code', '')
    belongs_to rel_name, :conditions => "list_name = '#{value}'", :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => key
  end
  
  def formatted_expiration_date
    expiration_date.nil? ? nil : expiration_date.to_s
  end

  def formatted_expiration_date=(expiration_date)
    self.expiration_date = expiration_date
  end
end
