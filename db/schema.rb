# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120810185448) do

  create_table "data_collection_tasks", :force => true do |t|
    t.integer  "staff_weekly_expense_id"
    t.date     "task_date"
    t.integer  "task_type_code"
    t.string   "task_type_other"
    t.decimal  "hours"
    t.decimal  "expenses"
    t.decimal  "miles"
    t.integer  "cases"
    t.integer  "transmit"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "staff_exp_data_coll_task_id", :limit => 36, :null => false
  end

  add_index "data_collection_tasks", ["staff_exp_data_coll_task_id"], :name => "uq_data_collection_tasks_staff_exp_data_coll_task_id", :unique => true

  create_table "inventory_items", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "management_tasks", :force => true do |t|
    t.integer  "staff_weekly_expense_id"
    t.date     "task_date",                             :null => false
    t.integer  "task_type_code",                        :null => false
    t.string   "task_type_other"
    t.decimal  "hours"
    t.decimal  "expenses"
    t.decimal  "miles"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "staff_exp_mgmt_task_id",  :limit => 36, :null => false
  end

  add_index "management_tasks", ["staff_exp_mgmt_task_id"], :name => "uq_management_tasks_staff_exp_mgmt_task_id", :unique => true

  create_table "miscellaneous_expenses", :force => true do |t|
    t.integer  "staff_weekly_expense_id"
    t.date     "expense_date"
    t.decimal  "expenses",                              :precision => 10, :scale => 2
    t.decimal  "miles",                                 :precision => 5,  :scale => 2
    t.string   "staff_misc_exp_id",       :limit => 36,                                :null => false
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "miscellaneous_expenses", ["staff_misc_exp_id"], :name => "uq_miscellaneous_expenses_staff_misc_exp_id", :unique => true

  create_table "ncs_area_ssus", :force => true do |t|
    t.integer "ncs_area_id"
    t.integer "ncs_ssu_id"
  end

  create_table "ncs_areas", :force => true do |t|
    t.string "psu_id", :null => false
    t.string "name",   :null => false
  end

  create_table "ncs_codes", :force => true do |t|
    t.string   "list_name",    :null => false
    t.string   "display_text", :null => false
    t.integer  "local_code",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ncs_ssus", :force => true do |t|
    t.string   "psu_id",     :limit => 36, :null => false
    t.string   "ssu_id",     :limit => 36, :null => false
    t.string   "ssu_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ncs_tsus", :force => true do |t|
    t.string   "psu_id",     :limit => 36, :null => false
    t.string   "tsu_id",     :limit => 36, :null => false
    t.string   "tsu_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "outreach_evaluations", :force => true do |t|
    t.integer  "outreach_event_id"
    t.integer  "evaluation_code",                      :null => false
    t.string   "evaluation_other"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "outreach_event_eval_id", :limit => 36, :null => false
    t.string   "source_id",              :limit => 36
  end

  add_index "outreach_evaluations", ["outreach_event_eval_id"], :name => "uq_outreach_evaluations_outreach_event_eval_id", :unique => true

  create_table "outreach_events", :force => true do |t|
    t.string   "event_date",             :limit => 10
    t.integer  "mode_code",                            :null => false
    t.string   "mode_other"
    t.integer  "outreach_type_code",                   :null => false
    t.string   "outreach_type_other"
    t.integer  "tailored_code",                        :null => false
    t.integer  "language_specific_code"
    t.integer  "race_specific_code"
    t.integer  "culture_specific_code"
    t.integer  "culture_code"
    t.string   "culture_other"
    t.decimal  "cost"
    t.integer  "no_of_staff"
    t.integer  "evaluation_result_code",               :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "letters_quantity"
    t.integer  "attendees_quantity"
    t.integer  "created_by"
    t.string   "outreach_event_id",      :limit => 36, :null => false
    t.string   "source_id",              :limit => 36
    t.date     "event_date_date"
  end

  add_index "outreach_events", ["outreach_event_id"], :name => "uq_outreach_events_outreach_event_id", :unique => true

  create_table "outreach_items", :force => true do |t|
    t.integer  "outreach_event_id"
    t.string   "item_name",         :null => false
    t.string   "item_other"
    t.integer  "item_quantity",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "outreach_languages", :force => true do |t|
    t.integer  "outreach_event_id"
    t.integer  "language_code",                   :null => false
    t.string   "language_other"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "outreach_lang2_id", :limit => 36, :null => false
    t.string   "source_id",         :limit => 36
  end

  add_index "outreach_languages", ["outreach_lang2_id"], :name => "uq_outreach_languages_outreach_lang2_id", :unique => true

  create_table "outreach_races", :force => true do |t|
    t.integer  "outreach_event_id"
    t.integer  "race_code",                       :null => false
    t.string   "race_other"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "outreach_race_id",  :limit => 36, :null => false
    t.string   "source_id",         :limit => 36
  end

  add_index "outreach_races", ["outreach_race_id"], :name => "uq_outreach_races_outreach_race_id", :unique => true

  create_table "outreach_segments", :force => true do |t|
    t.integer  "outreach_event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ncs_ssu_id"
    t.integer  "ncs_tsu_id"
  end

  create_table "outreach_staff_members", :force => true do |t|
    t.integer  "staff_id"
    t.integer  "outreach_event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "outreach_event_staff_id", :limit => 36, :null => false
    t.string   "source_id",               :limit => 36
  end

  add_index "outreach_staff_members", ["outreach_event_staff_id"], :name => "uq_outreach_staff_members_outreach_event_staff_id", :unique => true

  create_table "outreach_targets", :force => true do |t|
    t.integer  "outreach_event_id"
    t.integer  "target_code",                      :null => false
    t.string   "target_other"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "outreach_target_id", :limit => 36, :null => false
    t.string   "source_id",          :limit => 36
  end

  add_index "outreach_targets", ["outreach_target_id"], :name => "uq_outreach_targets_outreach_target_id", :unique => true

  create_table "roles", :force => true do |t|
    t.string "name", :null => false
  end

  create_table "staff", :force => true do |t|
    t.string   "email"
    t.string   "username"
    t.integer  "study_center"
    t.integer  "staff_type_code"
    t.string   "staff_type_other"
    t.integer  "subcontractor_code"
    t.integer  "gender_code"
    t.integer  "race_code"
    t.string   "race_other"
    t.integer  "ethnicity_code"
    t.integer  "experience_code"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "hourly_rate",                      :precision => 5,  :scale => 2
    t.date     "birth_date"
    t.string   "pay_type"
    t.decimal  "pay_amount",                       :precision => 10, :scale => 2
    t.string   "zipcode",            :limit => 5
    t.string   "first_name"
    t.string   "last_name"
    t.date     "ncs_active_date"
    t.date     "ncs_inactive_date"
    t.string   "staff_id",           :limit => 36,                                                   :null => false
    t.boolean  "external",                                                        :default => false, :null => false
    t.boolean  "notify",                                                          :default => true,  :null => false
    t.integer  "numeric_id",                                                                         :null => false
    t.integer  "age_group_code"
  end

  add_index "staff", ["numeric_id"], :name => "uq_staff_numeric_id", :unique => true
  add_index "staff", ["staff_id"], :name => "uq_staff_staff_id", :unique => true

  create_table "staff_cert_trainings", :force => true do |t|
    t.integer  "staff_id"
    t.integer  "certificate_type_code",               :null => false
    t.integer  "complete_code",                       :null => false
    t.string   "cert_date"
    t.integer  "background_check_code",               :null => false
    t.string   "frequency",             :limit => 10
    t.date     "expiration_date"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "staff_cert_list_id",    :limit => 36, :null => false
  end

  add_index "staff_cert_trainings", ["staff_cert_list_id"], :name => "uq_staff_cert_trainings_staff_cert_list_id", :unique => true

  create_table "staff_languages", :force => true do |t|
    t.integer  "staff_id"
    t.integer  "lang_code",                       :null => false
    t.string   "lang_other"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "staff_language_id", :limit => 36, :null => false
  end

  add_index "staff_languages", ["staff_language_id"], :name => "uq_staff_languages_staff_language_id", :unique => true

  create_table "staff_roles", :force => true do |t|
    t.integer  "staff_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "staff_weekly_expenses", :force => true do |t|
    t.integer  "staff_id"
    t.date     "week_start_date",                                             :null => false
    t.decimal  "rate",                          :precision => 5, :scale => 2
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "weekly_exp_id",   :limit => 36,                               :null => false
  end

  add_index "staff_weekly_expenses", ["weekly_exp_id"], :name => "uq_staff_weekly_expenses_weekly_exp_id", :unique => true

  create_table "supervisor_employees", :force => true do |t|
    t.integer "supervisor_id", :null => false
    t.integer "employee_id",   :null => false
  end

  add_index "supervisor_employees", ["supervisor_id", "employee_id"], :name => "un_supervisor_employee", :unique => true

end
