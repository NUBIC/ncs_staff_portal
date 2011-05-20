class CreateStaff < ActiveRecord::Migration
  def self.up
    create_table :staff do |t|
      t.string :name
      t.string :email
      t.string :netid
      t.integer :study_center
      t.integer :staff_type_code
      t.string :staff_type_other
      t.integer :subcontractor_code
      t.integer :yob
      t.integer :age_range_code
      t.integer :gender_code
      t.integer :race_code
      t.string :race_other
      t.integer :ethnicity_code
      t.integer :experience_code
      t.text :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :staff
  end
end
