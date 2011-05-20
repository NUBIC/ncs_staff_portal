class CreateStaffCertTrainings < ActiveRecord::Migration
  def self.up
    create_table :staff_cert_trainings do |t|
      t.references :staff
      t.integer :certificate_type_code
      t.integer :complete_code
      t.string :cert_date
      t.integer :background_check_code
      t.string :frequency
      t.date :expiration_date
      t.text :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :staff_cert_trainings
  end
end
