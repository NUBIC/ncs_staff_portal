class CreateOutreachTsus < ActiveRecord::Migration
  def self.up
    create_table :outreach_tsus do |t|
      t.references :outreach_event
      t.references :ncs_tsu
      t.timestamps
    end
    execute "ALTER TABLE outreach_tsus ADD CONSTRAINT fk_outreach_tsus_outreach_event FOREIGN KEY (outreach_event_id) REFERENCES outreach_events(id)"
    execute "ALTER TABLE outreach_tsus ADD CONSTRAINT fk_outreach_tsus_ncs_tsu FOREIGN KEY (ncs_tsu_id) REFERENCES ncs_tsus(id)"
  end

  def self.down
    execute "ALTER TABLE outreach_tsus DROP CONSTRAINT fk_outreach_tsus_outreach_event"
    execute "ALTER TABLE outreach_tsus DROP CONSTRAINT fk_outreach_tsus_ncs_tsu"
    drop_table :outreach_tsus
  end
end
