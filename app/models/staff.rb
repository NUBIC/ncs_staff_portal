class Staff < ActiveRecord::Base
  validates_presence_of :name, :netid, :study_center
  validates_presence_of :staff_type_code, :on => :update
  validates_uniqueness_of :netid
  validates :hourly_rate, :numericality => {:greater_than => 0, :allow_nil => true }
  validates :birth_date, :date => { :before => Date.today, :after => Date.today - 100.year ,:allow_nil => true }
  validates :email, :presence => true, :uniqueness => true, :format => {:with =>/^([^@\s]+)@((?:[-a-z0-9]+.)+[a-z]{2,})$/i }
  has_many :staff_languages
  has_many :staff_cert_trainings
  has_many :staff_weekly_expenses
  has_many :management_tasks, :through => :staff_weekly_expenses
  accepts_nested_attributes_for :staff_languages, :allow_destroy => true
  
  before_save :calculate_hourly_rate
  
  def calculate_hourly_rate
    unless pay_type.blank? && pay_amount.blank?
      if pay_type == "Hourly"
        self.hourly_rate = pay_amount
      elsif pay_type == "Yearly"
        self.hourly_rate = (pay_amount/1750).round(2)
      end
    end
  end
  
  def formatted_birth_date
    birth_date.nil? ? nil : birth_date.to_s
  end

  def formatted_birth_date=(birth_date)
    self.birth_date = birth_date
  end
  
  ATTRIBUTE_MAPPING = { 
    :staff_type_code => "STUDY_STAFF_TYPE_CL1",
    :age_range_code => "AGE_RANGE_CL1",
    :gender_code => "GENDER_CL1",
    :race_code => "RACE_CL1",
    :subcontractor_code => "CONFIRM_TYPE_CL2",
    :ethnicity_code => "ETHNICITY_CL1",
    :experience_code => "EXPERIENCE_LEVEL_CL1",
    :lang_code => "LANGUAGE_CL2",
    }
    
  ATTRIBUTE_MAPPING.each do |key, value|
    rel_name = key.to_s.gsub('_code', '')
    belongs_to rel_name, :conditions => "list_name = '#{value}'", :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => key
  end
end
