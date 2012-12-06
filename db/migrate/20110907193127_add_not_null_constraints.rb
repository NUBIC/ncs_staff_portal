class AddNotNullConstraints < ActiveRecord::Migration
  def self.up
    execute "UPDATE staff_cert_trainings SET background_check_code=1 WHERE background_check_code IS NULL"

    change_column(:management_tasks, :task_type_code, :integer, :null => false)
    change_column(:management_tasks, :task_date, :date, :null => false)
    change_column(:staff_weekly_expenses, :week_start_date, :date, :null => false)
    change_column(:staff_languages,:lang_code, :integer, :null => false)

    change_column(:staff_cert_trainings,:certificate_type_code, :integer, :null => false)
    change_column(:staff_cert_trainings,:complete_code, :integer, :null => false)
    change_column(:staff_cert_trainings,:background_check_code, :integer, :null => false)

    change_column(:ncs_areas, :psu_id, :string, :null => false)
    change_column(:ncs_areas, :name, :string, :null => false)
    change_column(:ncs_area_ssus, :ssu_id, :string, :null => false)

    change_column(:ncs_codes, :list_name, :string, :null => false)
    change_column(:ncs_codes, :display_text, :string, :null => false)
    change_column(:ncs_codes, :local_code, :integer, :null => false)

    change_column(:outreach_evaluations, :evaluation_code, :integer, :null => false)
    change_column(:outreach_languages, :language_code, :integer, :null => false)
    change_column(:outreach_races, :race_code, :integer, :null => false)
    change_column(:outreach_targets, :target_code, :integer, :null => false)
    change_column(:outreach_items, :item_name, :string, :null => false)
    change_column(:outreach_items, :item_quantity, :integer, :null => false)
  end

  def self.down
    change_column(:management_tasks, :task_type_code, :integer, :null => true)
    change_column(:management_tasks, :task_date, :date, :null => true)
    change_column(:staff_weekly_expenses, :week_start_date, :date, :null => true)
    change_column(:staff_languages,:lang_code, :integer, :null => true)

    change_column(:staff_cert_trainings,:certificate_type_code, :integer, :null => true)
    change_column(:staff_cert_trainings,:complete_code, :integer, :null => true)
    change_column(:staff_cert_trainings,:background_check_code, :integer, :null => true)

    change_column(:ncs_areas, :psu_id, :string, :null => true)
    change_column(:ncs_areas, :name, :string, :null => true)
    change_column(:ncs_area_ssus, :ssu_id, :string, :null => true)

    change_column(:ncs_codes, :list_name, :string, :null => true)
    change_column(:ncs_codes, :display_text, :string, :null => true)
    change_column(:ncs_codes, :local_code, :integer, :null => true)

    change_column(:outreach_evaluations, :evaluation_code, :integer, :null => true)
    change_column(:outreach_languages, :language_code, :integer, :null => true)
    change_column(:outreach_races, :race_code, :integer, :null => true)
    change_column(:outreach_targets, :target_code, :integer, :null => true)
    change_column(:outreach_items, :item_name, :string, :null => true)
    change_column(:outreach_items, :item_quantity, :integer, :null => true)
  end
end
