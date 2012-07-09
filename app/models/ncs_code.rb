# == Schema Information
#
# Table name: ncs_codes
#
#  id           :integer         not null, primary key
#  list_name    :string(255)     not null
#  display_text :string(255)     not null
#  local_code   :integer         not null
#  created_at   :datetime
#  updated_at   :datetime
#

class NcsCode < ActiveRecord::Base
  validates_presence_of :list_name, :display_text, :local_code
  ATTRIBUTE_MAPPING = { 
    :staff_type_code => "STUDY_STAFF_TYPE_CL1",
    :age_range_code => "AGE_RANGE_CL1",
    :gender_code => "GENDER_CL1",
    :race_code => "RACE_CL1",
    :subcontractor_code => "CONFIRM_TYPE_CL2",
    :ethnicity_code => "ETHNICITY_CL1",
    :experience_code => "EXPERIENCE_LEVEL_CL1",
    :lang_code => "LANGUAGE_CL2",
    :certificate_type_code => "CERTIFICATE_TYPE_CL1",
    :complete_code => "CONFIRM_TYPE_CL2",
    :background_check_code => "BACKGROUND_CHCK_LVL_CL1",
    :management_task_type_code => "STUDY_MNGMNT_TSK_TYPE_CL1",
    :outreach_target_code => "OUTREACH_TARGET_CL1",
    :outreach_evaluation_code => "OUTREACH_EVAL_CL1",
    :outreach_race_code => "RACE_CL3",
    :mode_code => "OUTREACH_MODE_CL1",
    :outreach_type_code => "OUTREACH_TYPE_CL1",
    :tailored_code => "CONFIRM_TYPE_CL2",
    :language_specific_code => "CONFIRM_TYPE_CL2",
    :language_code => "LANGUAGE_CL2",
    :race_specific_code => "CONFIRM_TYPE_CL6",
    :culture_specific_code => "CONFIRM_TYPE_CL6",
    :culture_code => "CULTURE_CL1",
    :evaluation_result_code => "SUCCESS_LEVEL_CL1",
    :data_collection_task_type_code => "STUDY_DATA_CLLCTN_TSK_TYPE_CL1"
    }

  def self.ncs_code_lookup(attribute_name)
    list_name = attribute_lookup(attribute_name)
    list = NcsCode.find_all_by_list_name(list_name).map do |n| 
      [n.display_text, n.local_code]
    end 
    list.select{ |pos| pos[1] >= 0 } + list.select{ |neg| neg[1] < 0 }   
  end
  
  def self.attribute_lookup(attribute_name)
     ATTRIBUTE_MAPPING[attribute_name]
  end
  
  def self.not_applicable_date
    return "9777-97-97"
  end
  
  def self.unknown_date
    return "9666-96-96"
  end
  
  def self.for_attribute_name_and_local_code(attribute_name, local_code)
    NcsCode.for_list_name_and_local_code(NcsCode.attribute_lookup(attribute_name), local_code)
  end

  def self.for_list_name_and_local_code(list_name, local_code)
    NcsCode.where(:list_name => list_name).where(:local_code => local_code.to_i).first
  end

  def self.for_list_name_and_display_text(list_name, display_text)
    NcsCode.where(:list_name => list_name).where(:display_text => display_text).first
  end
  
  def to_s
    display_text
  end

  def to_i
    local_code
  end

  def code
    local_code
  end
end
