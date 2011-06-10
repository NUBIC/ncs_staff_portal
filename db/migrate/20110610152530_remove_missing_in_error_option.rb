class RemoveMissingInErrorOption < ActiveRecord::Migration
  def self.up
    NcsCode.delete_all("local_code = -4 AND display_text = 'Missing in Error'")
  end

  def self.down
  end
end
