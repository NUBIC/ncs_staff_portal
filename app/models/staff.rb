# == Schema Information
#
# Table name: staff
#
#  id                 :integer          not null, primary key
#  email              :string(255)
#  username           :string(255)
#  staff_type_code    :integer
#  staff_type_other   :string(255)
#  subcontractor_code :integer
#  gender_code        :integer
#  race_code          :integer
#  race_other         :string(255)
#  ethnicity_code     :integer
#  experience_code    :integer
#  comment            :text
#  created_at         :datetime
#  updated_at         :datetime
#  hourly_rate        :decimal(5, 2)
#  birth_date         :date
#  pay_type           :string(255)
#  pay_amount         :decimal(10, 2)
#  zipcode            :string(5)
#  first_name         :string(255)
#  last_name          :string(255)
#  ncs_active_date    :date
#  ncs_inactive_date  :date
#  staff_id           :string(36)       not null
#  external           :boolean          default(FALSE), not null
#  notify             :boolean          default(TRUE), not null
#  numeric_id         :integer          not null
#  age_group_code     :integer
#  yob_staff          :integer
#

class Staff < ActiveRecord::Base
  include MdesRecord::ActsAsMdesRecord
  strip_attributes
  nilify_blanks
  self.include_root_in_json = false
  attr_accessor :validate_update, :validate_create
  validates_presence_of :staff_type, :gender, :race, :ethnicity, :subcontractor, :experience, :pay_type, :if => :update_presence_required?, :on => :update
  validates :zipcode, :numericality => true, :presence => true, :if => :update_presence_required?, :on => :update
  validates_date :birth_date, :before => Date.today, :after=> Date.today - 100.year, :allow_blank => true
  validates :birth_date, :presence => {:unless => "age_group_code", :message => ": You must enter birth date or select other option"}, :if => :update_presence_required?, :on => :update
  validates :email, :format => {:with =>/^([^@\s]+)@((?:[-a-z0-9]+.)+[a-z]{2,})$/i, :message => "is required when user have #{NcsNavigator.configuration.study_center_username}." }, :if => :email_required?
  validates_with OtherEntryValidator, :entry => :staff_type, :other_entry => :staff_type_other
  validates_with OtherEntryValidator, :entry => :race, :other_entry => :race_other
  validates_date :ncs_inactive_date, :allow_blank => true
  validates_uniqueness_of :username, :allow_blank => true, :allow_nil => true
  validate :pay_amount_required, :if => :update_presence_required?, :on => :update
  validates :staff_id, :presence => true, :uniqueness => { :message => "ID is already taken. Please choose different Staff ID." }
  has_many :staff_languages, :dependent => :destroy
  has_many :staff_cert_trainings, :dependent => :destroy
  has_many :staff_weekly_expenses, :dependent => :destroy
  has_many :management_tasks, :through => :staff_weekly_expenses
  has_many :data_collection_tasks, :through => :staff_weekly_expenses
  has_many :miscellaneous_expenses, :through => :staff_weekly_expenses
  has_many :staff_roles, :dependent => :destroy
  has_many :roles, :through => :staff_roles
  has_many :supervisor_employees, :foreign_key => :supervisor_id, :dependent => :destroy
  has_many :employees, :through => :supervisor_employees, :class_name => "Staff"

  accepts_nested_attributes_for :supervisor_employees, :allow_destroy => true
  accepts_nested_attributes_for :staff_roles, :allow_destroy => true
  accepts_nested_attributes_for :staff_languages, :allow_destroy => true

  ncs_coded_attribute :staff_type, 'STUDY_STAFF_TYPE_CL1'
  ncs_coded_attribute :age_range, 'AGE_RANGE_CL1'
  ncs_coded_attribute :gender, 'GENDER_CL1'
  ncs_coded_attribute :race, 'RACE_CL1'
  ncs_coded_attribute :subcontractor, 'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :ethnicity, 'ETHNICITY_CL1'
  ncs_coded_attribute :experience, 'EXPERIENCE_LEVEL_CL1'
  ncs_coded_attribute :lang, 'LANGUAGE_CL2'

  validate :has_roles, :if => :create_presence_required?
  def has_roles
    errors.add(:roles, "can not be empty when user has #{NcsNavigator.configuration.study_center_username}.User must have atleast one role assigned. Please select one or more roles.") if self.roles.blank? && !self.username.blank?
  end

  def email_required?
    !username.blank? && create_presence_required? ? true : false
  end

  before_save :calculate_hourly_rate, :update_employees

  acts_as_mdes_record :public_id => :staff_id
  before_create :generate_numeric_id

  def generate_numeric_id
    if self.numeric_id.blank?
      random = Staff.generate_random_number
      all_numeric_ids  = Staff.select([:numeric_id, :staff_id]).map(&:numeric_id)
      while all_numeric_ids.include?(random)
        random = Staff.generate_random_number
      end
      self.numeric_id = random
    end
  end

  def self.generate_random_number
    rand(2**31 - 1)
  end

  def pay_amount_required
    if self.pay_type == "Hourly" or self.pay_type =="Yearly"
      errors.add(:pay_amount, "can't be blank") if self.pay_amount.blank?
      errors.add(:pay_amount, "must be greater than 0") if !self.pay_amount.blank? and self.pay_amount <= 0
    end
  end

  def update_employees
    self.employees.delete_all unless self.has_role(Role::STAFF_SUPERVISOR)
  end

  def self.find_by_role(role)
    Staff.joins(:roles).where("roles.name IN (?)", role).uniq
  end

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
    super(
      :except => [
        :id, :pay_type, :pay_amount, :hourly_rate, :created_at, :updated_at, :comment,
        :staff_type_code, :age_range_code, :gender_code,:race_code, :subcontractor_code,
        :ethnicity_code, :experience_code, :birth_date
      ],
      :include =>[:roles]).merge(json)
  end

  def expenses_without_pay
    self.staff_weekly_expenses.where("rate = 0.00 or rate IS NULL")
  end

  def supervisors
    Staff.where("staff.id IN (select supervisor_id from supervisor_employees where employee_id = ?)", self.id)
  end

  def visible_employees
    @visible_employees ||= if employees.empty? && has_role(Role::STAFF_SUPERVISOR)
                             Staff.all
                           else
                             employees
                           end
  end

  def can_see_staff?(staff)
    if has_role(Roles::USER_ADMINISTRATOR)
      true
    else
      staff == self || visible_employees.any? { |e| e == staff }
    end
  end

  def belongs_to_management_group
    Role.management_group.any? { |role| self.has_role(role) } || !self.management_tasks.empty?
  end

  def belongs_to_data_collection_group
    Role.data_collection_group.any? { |role| self.has_role(role) } || !self.data_collection_tasks.empty?
  end

  def has_role(role_name)
    self.roles.map(&:name).include?(role_name)
  end

  def is_active
    (ncs_inactive_date.nil?) || (ncs_inactive_date != nil && ncs_inactive_date >= Time.now.to_date) ? true : false
  end

  def create_presence_required?
    validate_create == "true" ? true : false
  end

  def update_presence_required?
    validate_update == "false" ? false : true
  end

  def calculate_hourly_rate
    if pay_type == "Hourly"
      self.hourly_rate = pay_amount unless pay_amount.blank?
    elsif pay_type == "Yearly"
      self.hourly_rate = (pay_amount/2080).round(2) unless pay_amount.blank?
    elsif pay_type == "Voluntary"
      self.hourly_rate = 0
      self.pay_amount = 0
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
      reminder_staff << s unless StaffWeeklyExpense.find_by_week_start_date_and_staff_id(by_date.beginning_of_week, s.id)
    end
    reminder_staff
  end

  def name
    [first_name, last_name].reject(&:blank?).join(' ')
  end

  def last_name_first_name
    [last_name, first_name].reject(&:blank?).join(', ')
  end

  def display_username
    username ? username : staff_id
  end

  def display_name
    last_name_first_name.blank? ? staff_id : last_name_first_name
  end

  def display_birth_date
    if formatted_birth_date.blank?
      if age_group_code == NcsCode.refused_code
        "Refused"
      elsif age_group_code == NcsCode.unknown_code
        "Unknown"
      end
    else
      formatted_birth_date
    end
  end
end
