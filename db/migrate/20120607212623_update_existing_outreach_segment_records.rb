class UpdateExistingOutreachSegmentRecords < ActiveRecord::Migration
  class OutreachSegmentMigration < ActiveRecord::Base
    set_table_name "outreach_segments"
    belongs_to :outreach_event
    belongs_to :ncs_area
  end

  def self.up
    OutreachSegmentMigration.all.each do |segment|
      if segment.ncs_area
        segment.ncs_area.ncs_area_ssus.each do |area_ssu|
          OutreachSegment.create!(:outreach_event => segment.outreach_event, :ncs_ssu => area_ssu.ncs_ssu)
        end
      end
    end
    execute "DELETE FROM outreach_segments WHERE ncs_area_id IS NOT NULL AND ncs_ssu_id IS NULL"
  end

  def self.down
  end
end
