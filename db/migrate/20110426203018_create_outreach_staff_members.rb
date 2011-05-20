class CreateOutreachStaffMembers < ActiveRecord::Migration
  def self.up
    create_table :outreach_staff_members do |t|
      t.references :staff
      t.references :outreach_event
      t.timestamps
    end
  end

  def self.down
    drop_table :outreach_staff_members
  end
end
