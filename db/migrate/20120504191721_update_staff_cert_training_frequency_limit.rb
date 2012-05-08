class UpdateStaffCertTrainingFrequencyLimit < ActiveRecord::Migration
  def self.up
    change_column :staff_cert_trainings, :frequency, :string, :limit => 10
  end

  def self.down
    change_column :staff_cert_trainings, :frequency, :string
  end
end
