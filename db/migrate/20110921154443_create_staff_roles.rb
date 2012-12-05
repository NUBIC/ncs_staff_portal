class CreateStaffRoles < ActiveRecord::Migration
  def self.up
    create_table :staff_roles do |t|
      t.references :staff
      t.references :role
      t.timestamps
    end

    execute "ALTER TABLE staff_roles ADD CONSTRAINT fk_staff_roles_staff FOREIGN KEY (staff_id) REFERENCES staff(id)"
    execute "ALTER TABLE staff_roles ADD CONSTRAINT fk_staff_roles_role FOREIGN KEY (role_id) REFERENCES roles(id)"
  end

  def self.down
    drop_table :staff_roles
  end
end
