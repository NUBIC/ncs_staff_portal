class Staff < ActiveRecord::Base
  validates_presence_of :name, :netid, :study_center
  validates_presence_of :staff_type_code, :on => :update
  validates_uniqueness_of :netid
  validates :yob, :numericality => { :only_integer => true, :greater_than => Time.now.year - 150, :less_than => Time.now.year, :allow_nil => true }
  validates :email, :presence => true, :uniqueness => true, :format => {:with =>/^([^@\s]+)@((?:[-a-z0-9]+.)+[a-z]{2,})$/i }
  has_many :staff_languages
  has_many :staff_cert_trainings
  has_many :staff_weekly_expenses
  has_many :management_tasks, :through => :staff_weekly_expenses
  accepts_nested_attributes_for :staff_languages, :allow_destroy => true
  
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
