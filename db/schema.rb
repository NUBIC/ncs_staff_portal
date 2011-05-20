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

ActiveRecord::Schema.define(:version => 20110426203018) do

  create_table "management_tasks", :force => true do |t|
    t.integer  "staff_weekly_expense_id"
    t.date     "task_date"
    t.integer  "task_type_code"
    t.string   "task_type_other"
    t.decimal  "hours"
    t.decimal  "expenses"
    t.decimal  "miles"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ncs_codes", :force => true do |t|
    t.string   "list_name"
    t.string   "list_description"
    t.string   "display_text"
    t.integer  "local_code"
    t.string   "global_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "outreach_evaluations", :force => true do |t|
    t.integer  "outreach_event_id"
    t.integer  "evaluation_code"
    t.string   "evaluation_other"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "outreach_events", :force => true do |t|
    t.date     "event_date"
    t.integer  "mode_code"
    t.string   "mode_other"
    t.integer  "outreach_type_code"
    t.string   "outreach_type_other"
    t.integer  "tailored_code"
    t.integer  "language_specific_code"
    t.integer  "language_code"
    t.string   "language_other"
    t.integer  "race_specific_code"
    t.integer  "culture_specific_code"
    t.integer  "culture_code"
    t.string   "culture_other"
    t.integer  "quantity"
    t.decimal  "cost"
    t.integer  "no_of_staff"
    t.integer  "evaluation_result_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "outreach_races", :force => true do |t|
    t.integer  "outreach_event_id"
    t.integer  "race_code"
    t.string   "race_other"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "outreach_staff_members", :force => true do |t|
    t.integer  "staff_id"
    t.integer  "outreach_event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "outreach_targets", :force => true do |t|
    t.integer  "outreach_event_id"
    t.integer  "target_code"
    t.string   "target_other"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "staff", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "netid"
    t.integer  "study_center"
    t.integer  "staff_type_code"
    t.string   "staff_type_other"
    t.integer  "subcontractor_code"
    t.integer  "yob"
    t.integer  "age_range_code"
    t.integer  "gender_code"
    t.integer  "race_code"
    t.string   "race_other"
    t.integer  "ethnicity_code"
    t.integer  "experience_code"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "staff_cert_trainings", :force => true do |t|
    t.integer  "staff_id"
    t.integer  "certificate_type_code"
    t.integer  "complete_code"
    t.string   "cert_date"
    t.integer  "background_check_code"
    t.string   "frequency"
    t.date     "expiration_date"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "staff_languages", :force => true do |t|
    t.integer  "staff_id"
    t.integer  "lang_code"
    t.string   "lang_other"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "staff_weekly_expenses", :force => true do |t|
    t.integer  "staff_id"
    t.date     "week_start_date"
    t.decimal  "staff_pay"
    t.decimal  "staff_hours"
    t.decimal  "staff_expenses"
    t.decimal  "staff_miles"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
