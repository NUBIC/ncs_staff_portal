class OutreachEvent < ActiveRecord::Base
   has_many :outreach_staff_members
   has_many :outreach_races, :dependent => :destroy
   has_many :outreach_targets, :dependent => :destroy
   has_many :outreach_evaluations, :dependent => :destroy
   has_many :outreach_ssus, :dependent => :destroy
   has_many :outreach_tsus, :dependent => :destroy
   has_many :outreach_items, :dependent => :destroy
   accepts_nested_attributes_for :outreach_staff_members, :reject_if => :all_blank, :allow_destroy => true
   accepts_nested_attributes_for :outreach_races, :allow_destroy => true
   accepts_nested_attributes_for :outreach_targets, :allow_destroy => true
   accepts_nested_attributes_for :outreach_evaluations, :reject_if => :all_blank, :allow_destroy => true
   accepts_nested_attributes_for :outreach_ssus, :reject_if => :all_blank, :allow_destroy => true
   accepts_nested_attributes_for :outreach_items, :allow_destroy => true
   accepts_nested_attributes_for :outreach_tsus, :allow_destroy => true
   
   validates :event_date, :date => { :before => Date.today, :allow_nil => true }
   
   ATTRIBUTE_MAPPING = { 
     :mode_code => "OUTREACH_MODE_CL1",
     :outreach_type_code => "OUTREACH_TYPE_CL1",
     :tailored_code => "CONFIRM_TYPE_CL2",
     :language_specific_code => "CONFIRM_TYPE_CL2",
     :language_code => "LANGUAGE_CL2",
     :race_specific_code => "CONFIRM_TYPE_CL2",
     :culture_specific_code => "CONFIRM_TYPE_CL2",
     :culture_code => "CULTURE_CL1",
     :evaluation_result_code => "SUCCESS_LEVEL_CL1"
     }
     
   ATTRIBUTE_MAPPING.each do |key, value|
     rel_name = key.to_s.gsub('_code', '')
     belongs_to rel_name, :conditions => "list_name = '#{value}'", :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => key
   end
end
