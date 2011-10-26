# Schema Information
# Schema version: 20110406152435
#
# Table name: staff
#
# name                  :string
# email                 :string
# netid                 :string
# study_center          :integer
# staff_type_code       :integer
# staff_type_other      :string
# subcontractor_code    :integer
# birth_date            :date
# hourly_rate           :decimal
# pay_type              :string
# pay_hour              :decimal
# gender_code           :integer
# race_code             :integer
# race_other            :string
# zipcode               :integer
# ethnicity_code        :integer
# experience_code       :integer
# comment               :text


class Staff < ActiveRecord::Base
  self.include_root_in_json = false
  attr_accessor :validate_update, :validate_create
  validates_presence_of :first_name, :last_name, :username, :study_center, :if => :create_presence_required?
  validates_presence_of :staff_type, :birth_date, :gender, :race, :ethnicity, :zipcode, :subcontractor, :experience, :if => :update_presence_required?, :on => :update
  validates_uniqueness_of :username
  validates :pay_amount, :numericality => {:greater_than => 0, :allow_nil => true }
  validates_date :birth_date, :before => Date.today, :after=> Date.today - 100.year , :allow_nil => true
  validates :email, :presence => true, :uniqueness => true, :format => {:with =>/^([^@\s]+)@((?:[-a-z0-9]+.)+[a-z]{2,})$/i }, :if => :create_presence_required?
  validates_with OtherEntryValidator, :entry => :staff_type, :other_entry => :staff_type_other
  validates_with OtherEntryValidator, :entry => :race, :other_entry => :race_other
  validates_date :ncs_inactive_date, :allow_blank => true
  
  has_many :staff_languages, :dependent => :destroy
  has_many :staff_cert_trainings, :dependent => :destroy
  has_many :staff_weekly_expenses, :dependent => :destroy
  has_many :management_tasks, :through => :staff_weekly_expenses
  has_many :staff_roles, :dependent => :destroy
  has_many :roles, :through => :staff_roles
  has_many :supervisor_employees, :foreign_key => :supervisor_id, :dependent => :destroy
  has_many :employees, :through => :supervisor_employees, :class_name => "Staff"
  
  accepts_nested_attributes_for :supervisor_employees, :allow_destroy => true
  accepts_nested_attributes_for :staff_roles, :allow_destroy => true
  accepts_nested_attributes_for :staff_languages, :allow_destroy => true
  
  before_save :calculate_hourly_rate, :update_employees
  
  def update_employees
    self.employees.delete_all unless self.has_role(Role::STAFF_SUPERVISOR)
  end
  
  scope :with_role, lambda { |role| 
    joins(:roles).where('roles.name = ?', role)
  }
  
  scope :default_supervisors, lambda {
    joins(:roles).
    where("roles.name = 'Staff Supervisor' AND staff.id NOT IN (select supervisor_id from supervisor_employees)")
  }
  
  def as_json(options={})
    json = {}
    json["staff_type"] = self.staff_type ? self.staff_type.display_text : nil
    json["gender"] = self.gender ? self.gender.display_text : nil
    json["subcontractor"] = self.subcontractor ? self.subcontractor.display_text : nil
    json["race"] = self.race ? self.race.display_text : nil
    json["ethnicity"] =  self.ethnicity ? self.ethnicity.display_text : nil
    json["experience"] =  self.experience ? self.experience.display_text : nil
    json["languages"] = self.staff_languages.as_json
    super( :except => [ :id, :pay_type, :pay_amount, :hourly_rate, :created_at, :updated_at, :comment, 
                             :staff_type_code, :age_range_code, :gender_code,:race_code, :subcontractor_code, 
                             :ethnicity_code, :experience_code, :birth_date ], 
           :include =>[:roles]).merge(json)
  end
  
  def supervisors
    Staff.where("staff.id IN (select supervisor_id from supervisor_employees where employee_id = ?)", self.id)
  end
  
  def visible_employees
    visible_employees = self.employees
    visible_employees = Staff.all if visible_employees.empty? && has_role(Role::STAFF_SUPERVISOR)
    visible_employees
  end
  
  def has_role(role_name)
    self.roles.map(&:name).include?(role_name)
  end
  
  def is_active
    (ncs_inactive_date.nil?) || (ncs_inactive_date != nil && ncs_inactive_date >= Time.now.to_date) ? true : false
  end
  
  
  def update_presence_required?
    validate_update == "false" ? false : true
  end
  
  def create_presence_required?
    validate_create == "false" ? false : true
  end
  
  def name  
      [first_name, last_name].join(' ')  
  end
  
  def calculate_hourly_rate
    if !pay_type.blank? && !pay_amount.blank?
      if pay_type == "Hourly"
        self.hourly_rate = pay_amount
      elsif pay_type == "Yearly"
        self.hourly_rate = (pay_amount/1750).round(2)
      end
    else
      self.hourly_rate = 0
    end
  end
  
  def formatted_birth_date
    birth_date.nil? ? nil : birth_date.to_s
  end

  def formatted_birth_date=(birth_date)
    self.birth_date = birth_date
  end
  
  def formatted_ncs_inactive_date
    ncs_inactive_date.nil? ? nil : ncs_inactive_date.to_s
  end

  def formatted_ncs_inactive_date=(ncs_inactive_date)
    self.ncs_inactive_date = ncs_inactive_date
  end
  
  def self.by_task_reminder(by_date)
    reminder_staff = []
    Staff.all.each do |s| 
      if (s.staff_weekly_expenses.blank? || !s.staff_weekly_expenses.detect {|expense| expense.week_start_date == by_date.monday})
        reminder_staff << s
      end
    end
    reminder_staff
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
