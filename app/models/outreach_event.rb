# Schema Information
# Schema version: 20110426180246
#
# Table name: outreach_events
#
# event_date                  :date
# mode_code                   :integer
# mode_other                  :string
# outreach_type_code          :integer
# outreach_type_other         :string
# tailored_code               :integer
# language_specific_code      :integer
# language_code               :integer
# language_other              :string
# race_specific_code          :integer
# culture_specific_code       :integer
# culture_code                :integer
# culture_other               :string
# cost                        :decimal
# evaluation_result_code      :integer
# name                        :string
# letters_quantity            :integer
# attendees_quantity          :integer

class OutreachEvent < ActiveRecord::Base
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
   
   validates_presence_of :outreach_staff_members, :message => "can't be blank. Please add one or more staff members"
   validates_presence_of :outreach_evaluations, :message => "can't be blank. Please add one or more evaluations"
   validates_presence_of :outreach_targets, :message => "can't be blank. Please add one or more targets"
   validates_presence_of :name, :mode, :outreach_type, :tailored, :evaluation_result 
   validates_date :event_date, :on_or_before => Date.today
   validate :has_segments
   def has_segments
     errors.add(:base, "Outreach event must have atleast one segment. Please select one or more segments") if self.ncs_areas.blank?
   end
   
   scoped_search :on => [:name, :event_date]
   scoped_search :in => :ncs_areas, :on => :name
   scoped_search :in => :staff, :on => :name
   
   belongs_to :created_by_user, :class_name => 'Staff', :foreign_key => :created_by
   
   def formatted_event_date
     event_date.nil? ? nil : event_date.to_s
   end

   def formatted_event_date=(event_date)
     self.event_date = event_date
   end
   
   ATTRIBUTE_MAPPING = { 
     :mode_code => "OUTREACH_MODE_CL1",
     :outreach_type_code => "OUTREACH_TYPE_CL1",
     :tailored_code => "CONFIRM_TYPE_CL2",
     :language_specific_code => "CONFIRM_TYPE_CL2",
     :race_specific_code => "CONFIRM_TYPE_CL6",
     :culture_specific_code => "CONFIRM_TYPE_CL6",
     :culture_code => "CULTURE_CL1",
     :evaluation_result_code => "SUCCESS_LEVEL_CL1"
     }
     
   ATTRIBUTE_MAPPING.each do |key, value|
     rel_name = key.to_s.gsub('_code', '')
     belongs_to rel_name, :conditions => "list_name = '#{value}'", :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => key
   end
end
