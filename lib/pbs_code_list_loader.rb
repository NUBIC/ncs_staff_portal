class PbsCodeListLoader
  def self.load_codes
    [
      ['STUDY_MNGMNT_TSK_TYPE_CL1', 'PBS Frame Building', '12'],
      ['STUDY_MNGMNT_TSK_TYPE_CL1', 'Provider Recruitment', '13'],
      ['STUDY_MNGMNT_TSK_TYPE_CL1', 'PBS Frame Questionnaire', '14'],

      ['STUDY_DATA_CLLCTN_TSK_TYPE_CL1', 'PBS Participant Recruitment', '21'],
      ['STUDY_DATA_CLLCTN_TSK_TYPE_CL1', 'PBS Eligibility Screener', '22'],
      ['STUDY_DATA_CLLCTN_TSK_TYPE_CL1', 'PBS Frame Questionnaire', '23'],
    ].each do |list_name, text, code|
      NcsCode.find_or_create_by_list_name_and_display_text_and_local_code(list_name, text, code)
    end
  end

end