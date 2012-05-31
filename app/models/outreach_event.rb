# == Schema Information
#
# Table name: outreach_events
#
#  id                     :integer         not null, primary key
#  event_date             :date
#  mode_code              :integer         not null
#  mode_other             :string(255)
#  outreach_type_code     :integer         not null
#  outreach_type_other    :string(255)
#  tailored_code          :integer         not null
#  language_specific_code :integer
#  race_specific_code     :integer
#  culture_specific_code  :integer
#  culture_code           :integer
#  culture_other          :string(255)
#  cost                   :decimal(, )
#  no_of_staff            :integer
#  evaluation_result_code :integer         not null
#  created_at             :datetime
#  updated_at             :datetime
#  name                   :string(255)
#  letters_quantity       :integer
#  attendees_quantity     :integer
#  created_by             :integer
#  outreach_event_id      :string(36)      not null
#

class OutreachEvent < ActiveRecord::Base
  include MdesRecord::ActsAsMdesRecord
  acts_as_mdes_record :public_id => :outreach_event_id
  attr_accessor :import
  ncs_coded_attribute :mode, 'OUTREACH_MODE_CL1'
  ncs_coded_attribute :outreach_type, 'OUTREACH_TYPE_CL1'
  ncs_coded_attribute :tailored, 'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :language_specific, 'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :race_specific, 'CONFIRM_TYPE_CL6'
  ncs_coded_attribute :culture_specific, 'CONFIRM_TYPE_CL6'
  ncs_coded_attribute :culture, 'CULTURE_CL1'
  ncs_coded_attribute :evaluation_result, 'SUCCESS_LEVEL_CL1'
  
  has_many :outreach_staff_members, :dependent => :destroy
  has_many :outreach_races, :dependent => :destroy
  has_many :outreach_targets, :dependent => :destroy
  has_many :outreach_evaluations, :dependent => :destroy
  has_many :outreach_segments, :dependent => :destroy
  has_many :outreach_items, :dependent => :destroy
  has_many :outreach_languages, :dependent => :destroy
  has_many :ncs_areas, :through => :outreach_segments
  has_many :staff, :through => :outreach_staff_members
   
  accepts_nested_attributes_for :outreach_staff_members, :allow_destroy => true
  accepts_nested_attributes_for :outreach_races, :allow_destroy => true
  accepts_nested_attributes_for :outreach_targets, :allow_destroy => true
  accepts_nested_attributes_for :outreach_evaluations, :allow_destroy => true
  accepts_nested_attributes_for :outreach_segments, :allow_destroy => true
  accepts_nested_attributes_for :outreach_items, :allow_destroy => true
  accepts_nested_attributes_for :outreach_languages, :allow_destroy => true
   
  validates_presence_of :outreach_staff_members, :message => "can't be blank. Please add one or more staff members", :unless => :imported_mode
  validates_presence_of :outreach_evaluations, :message => "can't be blank. Please add one or more evaluations", :unless => :imported_mode
  validates_presence_of :outreach_targets, :message => "can't be blank. Please add one or more targets", :unless => :imported_mode
  validates_presence_of :name, :mode, :outreach_type, :tailored, :evaluation_result 
  validates_date :event_date, :on_or_before => :today, :allow_blank => true
  validates_with OtherEntryValidator, :entry => :mode, :other_entry => :mode_other
  validates_with OtherEntryValidator, :entry => :outreach_type, :other_entry => :outreach_type_other
  validates_with OtherEntryValidator, :entry => :culture, :other_entry => :culture_other
   
  validate :has_segments, :unless => :imported_mode
  def has_segments
    errors.add(:base, "Outreach event must have atleast one segment. Please select one or more segments") if self.ncs_areas.blank?
  end
   
  scoped_search :on => [:name, :event_date]
  scoped_search :in => :ncs_areas, :on => :name
  scoped_search :in => :staff, :on => [:first_name, :last_name]
   
  belongs_to :created_by_user, :class_name => 'Staff', :foreign_key => :created_by
  
  def imported_mode 
    import == "true" ? true : false
  end
   
  def formatted_event_date
    event_date.nil? ? "" : event_date.to_s
  end

  def formatted_event_date=(event_date)
    self.event_date = event_date
  end
   
  def mode_text
    self.mode.display_text == "Other" ? self.mode_other : self.mode.display_text
  end
   
  def outreach_type_text
    self.outreach_type.display_text == "Other" ? self.outreach_type_other : self.outreach_type.display_text
  end
   
  def created_by_user_text
    self.created_by.blank? ? nil : self.created_by_user.name
  end
   
  def name_text
    self.name.blank? ? nil : self.name
  end
   
end
