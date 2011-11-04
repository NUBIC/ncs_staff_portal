class CreateDataCollectionTasks < ActiveRecord::Migration
  def self.up
    create_table :data_collection_tasks do |t|
      t.references :staff_weekly_expense
      t.date :task_date
      t.integer :task_type_code
      t.string :task_type_other
      t.decimal :hours
      t.decimal :expenses
      t.decimal :miles
      t.integer :cases
      t.integer :transmit
      t.text :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :data_collection_tasks
  end
end
