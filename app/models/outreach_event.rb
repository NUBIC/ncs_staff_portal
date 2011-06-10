class OutreachEvent < ActiveRecord::Base
   has_many :outreach_staff_members
   has_many :outreach_races, :dependent => :destroy
   accepts_nested_attributes_for :outreach_staff_members, :allow_destroy => true
   has_many :outreach_targets, :dependent => :destroy
   has_many :outreach_evaluations, :dependent => :destroy
   after_update :save_races
   
   ATTRIBUTE_MAPPING = { 
     :mode_code => "OUTREACH_MODE_CL1",
     :outreach_type_code => "OUTREACH_TYPE_CL1",
     :tailored_code => "CONFIRM_TYPE_CL2",
     :language_specific_code => "CONFIRM_TYPE_CL2",
     :language_code => "LANGUAGE_CL2",
     :race_specific_code => "CONFIRM_TYPE_CL2",
     :culture_specific_code => "CONFIRM_TYPE_CL2",
     :culture_code => "CULTURE_CL1",
     :evaluation_result_code => "SUCCESS_LEVEL_CL1",
     :race_code => "RACE_CL3",
     :target_code => "OUTREACH_TARGET_CL1",
     :evaluation_code => "OUTREACH_EVAL_CL1"
     }
     
   ATTRIBUTE_MAPPING.each do |key, value|
     rel_name = key.to_s.gsub('_code', '')
     belongs_to rel_name, :conditions => "list_name = '#{value}'", :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => key
   end
   
   def race_attributes=(race_attributes) 
     race_attributes.each do |attributes|
       race = outreach_races.detect { |r| r.id == attributes[:id].to_i}
       if !attributes[:should_destroy].blank? && attributes[:should_destroy] == true
         race.delete
       else 
         race.attributes = attributes
       end
     end
   end
   
   def new_race_attributes=(race_attributes) 
     race_attributes.each do |attributes|
       outreach_races.build(attributes)
     end
   end
   
   def target_attributes=(target_attributes) 
     target_attributes.each do |attributes|
       outreach_targets.build(attributes)
     end
   end
   
   def evaluation_attributes=(evaluation_attributes) 
     evaluation_attributes.each do |attributes|
       outreach_evaluations.build(attributes)
     end
   end
   
   def save_races
     outreach_races.each do |race|
       race.save(:validate => false)
     end
   end
end
