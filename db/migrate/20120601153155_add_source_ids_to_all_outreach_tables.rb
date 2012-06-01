class AddSourceIdsToAllOutreachTables < ActiveRecord::Migration
  class << self
    SOURCE_ID_MODELS = [OutreachEvent,OutreachEvaluation, OutreachLanguage, OutreachRace, OutreachStaffMember, OutreachTarget]
    def up
      SOURCE_ID_MODELS.each do |model|
        add_source_id_column(model)
      end
    end

    def down
      SOURCE_ID_MODELS.collect(&:last).each do 
        remove_column :source_id
      end
    end

    private

    def add_source_id_column(model)
      add_column model.table_name, :source_id, :string, :limit => 36
    end
  end
end
