class UpdateNcsAreaSsuToUseNcsSsu < ActiveRecord::Migration
  def self.up
    add_column :ncs_area_ssus, :ncs_ssu_id, :integer, :references => "ncs_ssus"
    execute "ALTER TABLE ncs_area_ssus ADD CONSTRAINT fk_ncs_area_ssus_ncs_ssus FOREIGN KEY (ncs_ssu_id) REFERENCES ncs_ssus(id)"
    execute "UPDATE ncs_area_ssus nas SET ncs_ssu_id = (SELECT ns.id FROM ncs_ssus AS ns WHERE ns.ssu_id = nas.ssu_id)"
    remove_column(:ncs_area_ssus, :ssu_id)
    remove_column(:ncs_area_ssus, :ssu_name)
  end

  def self.down
    add_column(:ncs_area_ssus, :ssu_id, :string)
    add_column(:ncs_area_ssus, :ssu_name, :string)
    execute "UPDATE ncs_area_ssus nas SET ssu_id = (SELECT ns.ssu_id FROM ncs_ssus AS ns WHERE ns.id = nas.ncs_ssu_id)"
    execute "UPDATE ncs_area_ssus nas SET ssu_name = (SELECT ns.ssu_name FROM ncs_ssus AS ns WHERE ns.id = nas.ncs_ssu_id)"
    remove_column(:ncs_area_ssus, :ncs_ssu_id)
  end
end
