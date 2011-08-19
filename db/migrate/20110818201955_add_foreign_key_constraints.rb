class AddForeignKeyConstraints < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE staff_cert_trainings ADD CONSTRAINT fk_staff_cert_trainings_staff FOREIGN KEY (staff_id) REFERENCES staff(id)"
    execute "ALTER TABLE staff_languages ADD CONSTRAINT fk_staff_languages_staff FOREIGN KEY (staff_id) REFERENCES staff(id)"
    execute "ALTER TABLE staff_weekly_expenses ADD CONSTRAINT fk_staff_weekly_expenses_staff FOREIGN KEY (staff_id) REFERENCES staff(id)"
    
    # execute "ALTER TABLE management_tasks ADD CONSTRAINT fk_management_tasks_weekly_expense FOREIGN KEY (staff_weekly_expense_id) REFERENCES staff_weekly_expenses(id)"
    
    execute "ALTER TABLE outreach_races ADD CONSTRAINT fk_outreach_races_event FOREIGN KEY (outreach_event_id) REFERENCES outreach_events(id)"
    execute "ALTER TABLE outreach_targets ADD CONSTRAINT fk_outreach_targets_event FOREIGN KEY (outreach_event_id) REFERENCES outreach_events(id)"
    execute "ALTER TABLE outreach_evaluations ADD CONSTRAINT fk_outreach_evaluations_event FOREIGN KEY (outreach_event_id) REFERENCES outreach_events(id)"
    execute "ALTER TABLE outreach_languages ADD CONSTRAINT fk_outreach_languages_event FOREIGN KEY (outreach_event_id) REFERENCES outreach_events(id)"
    
    execute "ALTER TABLE outreach_items ADD CONSTRAINT fk_outreach_items_event FOREIGN KEY (outreach_event_id) REFERENCES outreach_events(id)"
    
    execute "ALTER TABLE outreach_segments ADD CONSTRAINT fk_outreach_segments_event FOREIGN KEY (outreach_event_id) REFERENCES outreach_events(id)"
    execute "ALTER TABLE outreach_segments ADD CONSTRAINT fk_outreach_segments_area FOREIGN KEY (ncs_area_id) REFERENCES ncs_areas(id)"
    
    execute "ALTER TABLE outreach_staff_members ADD CONSTRAINT fk_outreach_staff_members_event FOREIGN KEY (outreach_event_id) REFERENCES outreach_events(id)"
    execute "ALTER TABLE outreach_staff_members ADD CONSTRAINT fk_outreach_staff_members_staff FOREIGN KEY (staff_id) REFERENCES staff(id)"
    
    execute "ALTER TABLE ncs_area_ssus ADD CONSTRAINT fk_ncs_area_ssus_area FOREIGN KEY (ncs_area_id) REFERENCES ncs_areas(id)"
    
  end

  def self.down
    execute "ALTER TABLE staff_cert_trainings DROP CONSTRAINT fk_staff_cert_trainings_staff"
    execute "ALTER TABLE staff_languages DROP CONSTRAINT fk_staff_languages_staff"
    execute "ALTER TABLE staff_weekly_expenses DROP CONSTRAINT fk_staff_weekly_expenses_staff"
    
    # execute "ALTER TABLE management_tasks DROP CONSTRAINT fk_management_tasks_weekly_expense"
    
    execute "ALTER TABLE outreach_races DROP CONSTRAINT fk_outreach_races_event" 
    execute "ALTER TABLE outreach_targets DROP CONSTRAINT fk_outreach_targets_event" 
    execute "ALTER TABLE outreach_evaluations DROP CONSTRAINT fk_outreach_evaluations_event" 
    execute "ALTER TABLE outreach_languages DROP CONSTRAINT fk_outreach_languages_event"
    
    execute "ALTER TABLE outreach_items DROP CONSTRAINT fk_outreach_items_event" 
    
    execute "ALTER TABLE outreach_segments DROP CONSTRAINT fk_outreach_segments_event"
    execute "ALTER TABLE outreach_segments DROP CONSTRAINT fk_outreach_segments_area" 
    
    execute "ALTER TABLE outreach_staff_members DROP CONSTRAINT fk_outreach_staff_members_event" 
    execute "ALTER TABLE outreach_staff_members DROP CONSTRAINT fk_outreach_staff_members_staff" 
    
    execute "ALTER TABLE ncs_area_ssus DROP CONSTRAINT fk_ncs_area_ssus_area" 
  end
end
