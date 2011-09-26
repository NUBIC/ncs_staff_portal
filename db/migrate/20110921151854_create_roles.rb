class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :name, :null => false
    end
    
    execute "INSERT into roles (name) values ('System Administrator')"
    execute "INSERT into roles (name) values ('User Administrator')"
    execute "INSERT into roles (name) values ('Staff Supervisor')"
    execute "INSERT into roles (name) values ('Field Staff')"
    execute "INSERT into roles (name) values ('Phone Staff')"
    execute "INSERT into roles (name) values ('Outreach Staff')"
    execute "INSERT into roles (name) values ('Biological Specimen Collector')"
    execute "INSERT into roles (name) values ('Specimen Processor')"
    execute "INSERT into roles (name) values ('Data Manager')"
  end

  def self.down
    drop_table :roles
  end
end
