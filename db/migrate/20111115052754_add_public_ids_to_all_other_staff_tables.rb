class AddPublicIdsToAllOtherStaffTables < ActiveRecord::Migration
  class << self
    PUBLIC_ID_NAMES = [
      [StaffLanguage,      :staff_language_id],
      [StaffCertTraining,  :staff_cert_list_id],
      [StaffWeeklyExpense, :weekly_exp_id],
      [ManagementTask,     :staff_exp_mgmt_task_id],
      [DataCollectionTask, :staff_exp_data_coll_task_id]
    ]

    def up
      PUBLIC_ID_NAMES.each do |model, name|
        add_public_id_column(model, name)
      end
    end

    def down
      PUBLIC_ID_NAMES.collect(&:last).each do |name|
        remove_column name
      end
    end

    private

    def add_public_id_column(model, public_id_name)
      add_column model.table_name, public_id_name, :string, :limit => 36
      add_index model.table_name, public_id_name,
        :unique => true, :name => "uq_#{model.table_name}_#{public_id_name}"
      model.reset_column_information
      model.find(:all).each do |instance|
        instance.update_attribute public_id_name,
          MdesRecord::ActsAsMdesRecord.create_public_id_string
      end
      change_column model.table_name, public_id_name, :string, :limit => 36, :null => false
    end
  end
end
