class RenameNetidToUsername < ActiveRecord::Migration
  def self.up
    rename_column(:staff, :netid, :username)
  end

  def self.down
    rename_column(:staff, :username, :netid)
  end
end
