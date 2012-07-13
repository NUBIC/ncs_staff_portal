# == Schema Information
#
# Table name: outreach_events
#
#  id                     :integer         not null, primary key
#  event_date             :string(10)
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
#  source_id              :string(36)
#  event_date_date        :date
#

class OutreachEvent < ActiveRecord::Base
  include MdesRecord::ActsAsMdesRecord
  
  MDES_DATE_FORMAT = '^\d{4}-(9[13467]-(9[13467]|(0[1-9]|1[0-9]|2[0-9]|3[01]))|(0[1-9]|1[0-2])-(9[13467]|(0[1-9]|1[0-9]|2[0-9]))|(0[13578]|1[02])-31|(0[1,3-9]|1[0-2])-30)$'
  
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
  has_many :ncs_ssus, :through => :outreach_segments
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

  validates_with OtherEntryValidator, :entry => :mode, :other_entry => :mode_other
  validates_with OtherEntryValidator, :entry => :outreach_type, :other_entry => :outreach_type_other
  validates_with OtherEntryValidator, :entry => :culture, :other_entry => :culture_other
  validate :valid_event_date 
  validate :has_segments, :unless => :imported_mode
  before_save :convert_date
  
  def valid_event_date
    errors.add(:event_date, "#{event_date} is not the valid mdes format date.") unless mdes_formatted_date
  end
  
  def has_segments
    errors.add(:base, "Outreach event must have atleast one segment. Please select one or more segments") if self.ncs_ssus.blank?
  end
   
  belongs_to :created_by_user, :class_name => 'Staff', :foreign_key => :created_by
  
  def imported_mode 
    import == "true" ? true : false
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
  
  private
    def only_date
      begin
        Date.parse(event_date)
        true
      rescue
        false
      end
    end
    
    #TODO: move mdes_formatted_date to the MdesRecord module
    def mdes_formatted_date
      event_date.blank? ? true : only_date || event_date.match(MDES_DATE_FORMAT) ? true : false
    end
   
    def convert_date
      self.event_date_date = only_date ? event_date : nil
    end
end
