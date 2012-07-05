class RemoveUnusedAttributesFromNcsCode < ActiveRecord::Migration
  def self.up
    remove_column :ncs_codes, :global_code
    remove_column :ncs_codes, :list_description
  end

  def self.down
    add_column :ncs_codes, :list_description, :string
    add_column :ncs_codes, :global_code, :string
  end
end
