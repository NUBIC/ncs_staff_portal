
FactoryGirl.define do
  factory :ncs_code do |code|
    code.list_name        "CONFIRM_TYPE_CL2"
    code.display_text     "YES"
    code.local_code       1
  end

  factory :staff do |s|
    s.first_name "FName"
    s.last_name "LName"
    s.email {Factory.next(:email)}
    s.study_center 123456
  end

  factory :valid_staff, :class => Staff do |s|
    s.first_name 'Josephine'
    s.last_name  'Hull'
    s.study_center 2900092
    s.birth_date Date.new(1977, 1, 3)
    s.staff_type    { |a| a.association(:ncs_code, :list_name => 'STUDY_STAFF_TYPE_CL1', :local_code => 12, :display_text => 'Telephone Center Staff') }
    s.gender        { |a| a.association(:ncs_code, :list_name => 'GENDER_CL1', :local_code => 2, :display_text => 'Female') }
    s.race          { |a| a.association(:ncs_code, :list_name => 'RACE_CL1', :local_code => 1, :display_text => 'White') }
    s.subcontractor { |a| a.association(:ncs_code, :list_name => 'CONFIRM_TYPE_CL2', :local_code => 1, :display_text => 'Yes') }
    s.ethnicity     { |a| a.association(:ncs_code, :list_name => 'ETHNICITY_CL1', :local_code => 2, :display_text => 'Not Hispanic or Latino') }
    s.experience    { |a| a.association(:ncs_code, :list_name => 'EXPERIENCE_LEVEL_CL1', :local_code => 3, :display_text => '6 or more years') }
    s.pay_type 'Hourly'
    s.pay_amount '6.95'
    s.zipcode '92131'
  end

  factory :staff_language do |sl|
    sl.association :staff, :factory => :staff
    sl.lang {|a| a.association(:ncs_code, :list_name => "LANGUAGE_CL2", :display_text => "English", :local_code => 1) }
  end

  factory :staff_cert_training do |cert|
    cert.association :staff, :factory => :staff
    cert.certificate_type {|a| a.association(:ncs_code, :list_name => "CERTIFICATE_TYPE_CL1", :display_text => "Certified to conduct specific assessment", :local_code => 1) }
    cert.complete {|a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL2", :display_text => "No", :local_code => 2) }
    cert.background_check {|a| a.association(:ncs_code, :list_name => "BACKGROUND_CHCK_LVL_CL1", :display_text => "A", :local_code => 1) }
  end

  factory :staff_weekly_expense do |task|
    task.week_start_date Date.today.monday
    task.association :staff, :factory => :staff
  end

  factory :management_task do |task|
    task.task_type {|a| a.association(:ncs_code, :list_name => "STUDY_MNGMNT_TSK_TYPE_CL1", :display_text => "NCS Management", :local_code => 1) }
    task.task_date Date.today
    task.hours nil
    task.miles nil
    task.expenses nil
    task.association :staff_weekly_expense, :factory => :staff_weekly_expense
  end

  factory :data_collection_task do |task|
    task.task_type {|a| a.association(:ncs_code, :list_name => "STUDY_DATA_CLLCTN_TSK_TYPE_CL1", :display_text => "Field Management", :local_code => 1) }
    task.task_date Date.today
    task.hours nil
    task.miles nil
    task.expenses nil
    task.association :staff_weekly_expense, :factory => :staff_weekly_expense
  end
  
  factory :miscellaneous_expense do |m_expense|
    m_expense.expense_date  Date.today
    m_expense.miles nil
    m_expense.expenses nil
    m_expense.association :staff_weekly_expense, :factory => :staff_weekly_expense
  end

  factory :outreach_event do |event|
    event.name "test"
    event.mode {|a| a.association(:ncs_code, :list_name => "OUTREACH_MODE_CL1", :display_text => "In-person", :local_code => 1) }
    event.outreach_type {|a| a.association(:ncs_code, :list_name => "OUTREACH_TYPE_CL1", :display_text => "Letters", :local_code => 1) }
    event.tailored {|a| a.association(:ncs_code, :list_name => "CONFIRM_TYPE_CL2", :display_text => "Yes", :local_code => 1) }
    event.evaluation_result {|a| a.association(:ncs_code, :list_name => "SUCCESS_LEVEL_CL1", :display_text => "Very Successful", :local_code => 1) }
    event.event_date "2012-05-12"
    event.outreach_staff_members {|a| [a.association(:outreach_staff_member)]}
    event.outreach_evaluations {|a| [a.association(:outreach_evaluation)]}
    event.outreach_targets {|a| [a.association(:outreach_target)]}
    event.outreach_segments {|a| [a.association(:outreach_segment)]}
    event.import "true"
  end

  factory :outreach_staff_member do |member|
    member.association :staff, :factory => :staff
  end

  factory :outreach_evaluation do |eval|
    eval.evaluation {|a| a.association(:ncs_code, :list_name => "OUTREACH_EVAL_CL1", :display_text => "Focus groups", :local_code => 1) }
  end

  factory :outreach_target do |tar|
    tar.target {|a| a.association(:ncs_code, :list_name => "OUTREACH_TARGET_CL1", :display_text => "Building manager", :local_code => 10) }
  end

  factory :outreach_race do |r|
    r.race {|a| a.association(:ncs_code, :list_name => "RACE_CL3", :display_text => "White", :local_code => 1) }
    r.association :outreach_event, :factory => :outreach_event
  end

  factory :outreach_language do |l|
    l.language {|a| a.association(:ncs_code, :list_name => "LANGUAGE_CL2", :display_text => "English", :local_code => 1) }
    l.association :outreach_event, :factory => :outreach_event
  end

  factory :outreach_item do |item|
    item.association :outreach_event, :factory => :outreach_event
    item.item_name "Bag"
    item.item_quantity 2
  end

  factory :ncs_area do |area|
    area.psu_id "0012345"
    area.name {Factory.next(:area_name)}
  end
  
  factory :ncs_ssu do |ssu|
    ssu.psu_id "0012345"
    ssu.ssu_id { Factory.next(:ssu) }
    ssu.ssu_name { Factory.next(:ssu) }
  end
  
  factory :ncs_area_ssu do |ssu|
    ssu.association :ncs_area, :factory => :ncs_area
    ssu.association :ncs_ssu, :factory => :ncs_ssu
  end

  factory :outreach_segment do |segment|
    segment.association :ncs_ssu, :factory => :ncs_ssu
  end
  
  factory :ncs_tsu do |tsu|
    tsu.psu_id "0012345"
    tsu.tsu_id { Factory.next(:tsu) }
    tsu.tsu_name { Factory.next(:tsu) }
  end
  
  sequence :area_name do |n|
    "area_name#{n}"
  end
  
  sequence :tsu do |n|
    "tsu_#{n}"
  end
  
  sequence :ssu do |n|
    "ssu_#{n}"
  end

  sequence :user_name do |n|
    "user_name#{n}"
  end

  sequence :email do |n|
    "email#{n}@test.com"
  end

  factory :role do |r|
    r.name {Factory.next(:role_name)}
  end

  sequence :role_name do |n|
    "role_name#{n}"
  end

  factory :staff_role do |sr|
    sr.association :staff, :factory => :staff
    sr.association :role, :factory => :role
  end

end
