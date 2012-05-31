# == Schema Information
#
# Table name: staff_cert_trainings
#
#  id                    :integer         not null, primary key
#  staff_id              :integer
#  certificate_type_code :integer         not null
#  complete_code         :integer         not null
#  cert_date             :string(255)
#  background_check_code :integer         not null
#  frequency             :string(10)
#  expiration_date       :date
#  comment               :text
#  created_at            :datetime
#  updated_at            :datetime
#  staff_cert_list_id    :string(36)      not null
#

class StaffCertTraining < ActiveRecord::Base
  include MdesRecord::ActsAsMdesRecord
  validates_presence_of :certificate_type, :complete, :background_check
  belongs_to :staff
  validates_date :expiration_date, :allow_blank => true
  validate :valid_cert_date
  before_save :format_cert_date
  acts_as_mdes_record :public_id => :staff_cert_list_id
  validates :frequency, :length => { :maximum => 10 }
  
  ncs_coded_attribute :certificate_type, 'CERTIFICATE_TYPE_CL1'
  ncs_coded_attribute :complete, 'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :background_check, 'BACKGROUND_CHCK_LVL_CL1'
  
  def format_cert_date
    self.cert_date = cert_date.to_date.strftime("%Y-%m-%d") if !cert_date.blank? && only_date 
  end
  
  def valid_cert_date
    if only_date
      validates_date :cert_date, :allow_blank => complete_code == 1 ? false : true
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
  
  def only_date
    (cert_date != NcsCode.unknown_date && cert_date != NcsCode.not_applicable_date) ? true : false
  end
  
  def certificate_type_text
    self.certificate_type.display_text == "Other" ? self.certificate_type_other : self.certificate_type.display_text
  end
end
