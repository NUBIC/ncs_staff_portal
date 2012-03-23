class ModifyRoleName < ActiveRecord::Migration
  def self.up
    execute "UPDATE roles SET name='Data Reader' WHERE name='Data Manager'"
  end

  def self.down
    execute "UPDATE roles SET name='Data Manager' WHERE name='Data Reader'"
  end
end
