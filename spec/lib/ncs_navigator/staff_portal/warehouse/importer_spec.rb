require 'spec_helper'

require 'ncs_navigator/staff_portal/warehouse'

require File.expand_path('../importer_warehouse_setup', __FILE__)

module NcsNavigator::StaffPortal::Warehouse
  describe Importer, :clean_with_truncation, :warehouse do
    MdesModule = NcsNavigator::Warehouse::Models::TwoPointZero

    include_context :importer_spec_warehouse
    
    let(:importer) {
      Importer.new(wh_config)
    }

    let(:enumerator) {
      Enumerator.new(wh_config, :bcdatabase => bcdatabase_config)
    }

    def save_wh(record)
      record.psu_id = 20000030
      unless record.save
        messages = record.errors.keys.collect { |prop|
          record.errors[prop].collect { |e|
            v = record.send(prop)
            "#{e} (#{prop}=#{v.inspect})."
          }
        }.flatten
        fail "Could not save #{record} due to validation failures: #{messages.join(', ')}"
      end
      record
    end

    def create_warehouse_record_with_defaults(mdes_model, attributes={})
      save_wh(mdes_model.new(all_missing_attributes(mdes_model).merge(attributes)))
    end
    
    describe 'strategy selection' do
      it 'handles most models automatically' do
        Importer.automatic_producers.size.should == 13
      end
    end
    
    describe 'automatic conversion' do
      describe 'of an existing record' do
        let!(:sp_staff) { Factory(:valid_staff) }
        let!(:mdes_staff) { enumerator.to_a(:staff).first.tap { |p| 
          save_wh(p) } }
        
        let!(:sp_record) { Factory(:staff_cert_training, :staff => sp_staff, :updated_at => Date.new(2010, 1, 1)) }
        let!(:mdes_record) { enumerator.to_a(:staff_cert_trainings).first.tap { |p| 
          save_wh(p) } }
          
        describe 'when it is identical' do
          before do
            importer.import(:staff_cert_trainings)
          end

          it 'does nothing to the existing record' do
           StaffCertTraining.first.updated_at.to_date.should == Date.new(2010, 1, 1)
          end
          
          it 'does not add a new record' do
            StaffCertTraining.count.should == 1
          end
        end
        
        describe 'when a scalar field is updated' do
          before do
            mdes_record.cert_type_frequency = "10 Times"
            save_wh(mdes_record)
            importer.import(:staff_cert_trainings)
          end

          it 'updates that scalar field in staff portal' do
            StaffCertTraining.first.frequency.should == "10 Times"
          end

          it 'does not add a new record' do
            StaffCertTraining.count.should == 1
          end
        end

        describe 'when an entity association is changed' do
          let!(:sp_second_staff) { Factory(:valid_staff, :username => "new", :email => "new@test.com", :zipcode => 33333) } 
          let!(:mdes_second_staff) { enumerator.to_a(:staff).second.tap { |p| save_wh(p) } }

          before do
            mdes_record.staff_id = sp_second_staff.public_id
            save_wh(mdes_record)

            importer.import(:staff_cert_trainings)
          end

          it 'updates the association to the core object' do
            StaffCertTraining.first.staff.zipcode.should == 33333
            StaffCertTraining.first.staff.id.should_not == sp_staff.id
          end

          it 'does not add a new record' do
            StaffCertTraining.count.should == 1
          end
        end
      end
      
      describe 'of a completely new record' do
        let!(:sp_staff) { Factory(:valid_staff) }
        let!(:mdes_staff) { enumerator.to_a(:staff).first.tap { |p| 
          save_wh(p) } }

        let!(:mdes_record) {
          Factory(:staff_cert_training, :staff => sp_staff, :frequency => "3yrs")
          enumerator.to_a(:staff_cert_trainings).first.tap do |a|
            save_wh(a)
            StaffCertTraining.destroy_all
            StaffCertTraining.count.should == 0
          end
        }
        
        before do
          importer.import(:staff_cert_trainings)
        end

        it 'creates a new record' do
          StaffCertTraining.count.should == 1
        end

        it 'creates a new record with appropriate scalar values' do
          StaffCertTraining.first.frequency.should == "3yrs"
        end

        it 'creates a new record with correct entity associations' do
          StaffCertTraining.first.staff.id. == sp_staff.id
        end

        it 'creates a new record with correct code associations' do
          StaffCertTraining.first.background_check_code.should == 1
        end
      end
    end
    
    describe 'conversion for staff' do
      describe 'of a completely new record' do
        let!(:sp_staff) { Factory(:valid_staff) }
        let!(:mdes_staff) { enumerator.to_a(:staff).first.tap { |p| 
          save_wh(p) 
          Staff.destroy_all
          Staff.count.should == 0 } }
          
        before do
          importer.import(:staff)
        end
        
        it 'creates a new record' do
          Staff.count.should == 1
        end
        
        it 'creates a new record with appropriate zipcode' do
          Staff.first.zipcode.should == 92131         
        end
        
        it 'creates a new record with age range set' do
          Staff.first.age_group_code.should == 4
        end
        
        it 'creates a new record with correct code associations' do
          Staff.first.gender_code.should == 2
        end        
      end
    end
    
    describe 'conversion for staff_languages' do
      describe 'of a completely new record' do
        let!(:sp_staff) { Factory(:valid_staff) }
        let!(:mdes_staff) { enumerator.to_a(:staff).first.tap { |p| 
          save_wh(p) } }

        let!(:mdes_record) {
          Factory(:staff_language, :staff => sp_staff)
          enumerator.to_a(:staff_languages).first.tap do |a|
            save_wh(a)
            StaffLanguage.destroy_all
            StaffLanguage.count.should == 0
          end
        }
          
        before do
          importer.import(:staff_languages)
        end
        
        it 'creates a new record' do
          StaffLanguage.count.should == 1
        end
        
        it 'creates a new record with correct code associations' do
          StaffLanguage.first.lang_code.should == 1
        end 
        
        it 'creates a new record with appropriate other language' do
          StaffLanguage.first.lang_other.should == nil         
        end       
      end
      
      describe 'of a completely new record with other value' do
        let(:other_code) { Factory(:ncs_code, :list_name => "LANGUAGE_CL2", :display_text => "Other", :local_code => -5) }
        let!(:sp_staff) { Factory(:valid_staff) }
        let!(:mdes_staff) { enumerator.to_a(:staff).first.tap { |p| 
          save_wh(p) } }
      
        let!(:mdes_record) {
          Factory(:staff_language, :lang => other_code, :lang_other => 'Esperanto', :staff => sp_staff)
          enumerator.to_a(:staff_languages_other).first.tap do |a|
            save_wh(a)
            StaffLanguage.destroy_all
            StaffLanguage.count.should == 0
          end
        }
          
        before do
          importer.import(:staff_languages)
        end
        
        it 'creates a new record' do
          StaffLanguage.count.should == 1
        end
        
        it 'creates a new record with correct code associations' do
          StaffLanguage.first.lang_code.should == -5
        end 
        
        it 'creates a new record with appropriate other language' do
          StaffLanguage.first.lang_other.should == 'Esperanto'         
        end       
      end
      
      describe 'of a completely new record with two other value' do
        let(:other_code) { Factory(:ncs_code, :list_name => "LANGUAGE_CL2", :display_text => "Other", :local_code => -5) }
        let!(:sp_staff) { Factory(:valid_staff) }
        let!(:mdes_staff) { enumerator.to_a(:staff).first.tap { |p| 
          save_wh(p) } }
      
        let!(:mdes_record) {
          Factory(:staff_language, :lang => other_code, :lang_other => 'Esperanto', :staff => sp_staff)
          Factory(:staff_language, :lang => other_code, :lang_other => 'Gujarati', :staff => sp_staff)
          enumerator.to_a(:staff_languages_other).first.tap do |a|
            save_wh(a)
            StaffLanguage.destroy_all
            StaffLanguage.count.should == 0
          end
        }
          
        before do
          importer.import(:staff_languages)
        end
         
        it 'creates mutiple new record' do
          StaffLanguage.count.should == 2
        end
        
        it 'creates a new record with correct code associations' do
          StaffLanguage.first.lang_code.should == -5
        end 
        
        it 'creates a new record with appropriate other language' do
          StaffLanguage.first.lang_other.should == 'Gujarati'         
        end  
        
        it 'creates a new record with appropriate other language' do
          StaffLanguage.all.second.lang_other.should == 'Esperanto'         
        end     
      end
      
      describe 'of a completely new record with three other value' do
        let(:other_code) { Factory(:ncs_code, :list_name => "LANGUAGE_CL2", :display_text => "Other", :local_code => -5) }
        let!(:sp_staff) { Factory(:valid_staff) }
        let!(:mdes_staff) { enumerator.to_a(:staff).first.tap { |p| 
          save_wh(p) } }
      
        let!(:mdes_record) {
          Factory(:staff_language, :lang => other_code, :lang_other => 'Esperanto', :staff => sp_staff)
          Factory(:staff_language, :lang => other_code, :lang_other => 'Gujarati', :staff => sp_staff)
          Factory(:staff_language, :lang => other_code, :lang_other => 'Hindi', :staff => sp_staff)
          enumerator.to_a(:staff_languages_other).first.tap do |a|
            save_wh(a)
            StaffLanguage.destroy_all
            StaffLanguage.count.should == 0
          end
        }
          
        before do
          importer.import(:staff_languages)
        end
         
        it 'creates mutiple new record' do
          StaffLanguage.count.should == 3
        end
        
        it 'creates a new record with correct code associations' do
          StaffLanguage.first.lang_code.should == -5
        end 
        
        it 'creates a new record with appropriate other language' do
          StaffLanguage.first.lang_other.should == 'Gujarati'         
        end  
        
        it 'creates a new record with appropriate other language' do
          StaffLanguage.all.second.lang_other.should == 'Hindi'         
        end
        
        it 'creates a new record with appropriate other language' do
          StaffLanguage.all.third.lang_other.should == 'Esperanto'         
        end     
      end
    end
    
    describe 'conversion for staff weekly expense' do
      describe 'of a completely new record' do
        let!(:sp_staff) { Factory(:valid_staff) }
        let!(:mdes_staff) { enumerator.to_a(:staff).first.tap { |p| 
          save_wh(p) } }

        let!(:mdes_record) {
          Factory(:staff_weekly_expense, :staff => sp_staff, :rate => 32.50)
          enumerator.to_a(:staff_weekly_expenses).first.tap do |a|
            a.staff_expenses = 200
            a.staff_miles = 15.7
            save_wh(a)
            StaffWeeklyExpense.destroy_all
            StaffWeeklyExpense.count.should == 0
          end
        }
          
        before do
          importer.import(:staff_weekly_expenses)
        end
        
        it 'creates a new record' do
          StaffWeeklyExpense.count.should == 1
        end
        
        it 'creates a new record with correct staff pay association' do
          StaffWeeklyExpense.first.rate.should == 32.50
        end 
        
        describe "for expenses and miles as miscellaneous expense" do
          it 'creates a new record' do
            MiscellaneousExpense.count.should == 1
          end
          
          it "records weekly expenses correctly" do
            MiscellaneousExpense.first.expenses.should == 200
          end
          
          it "records weekly miles correctly" do
            MiscellaneousExpense.first.miles.should == 15.7
          end
          
          it "records comment inidicating imported to staff portal" do
            MiscellaneousExpense.first.comment.should == "Imported to staff portal"
          end
        end
      end
    end
      
    describe 'conversion for management task' do
      describe 'of a completely new record' do
        let!(:sp_staff) { Factory(:valid_staff) }
        let!(:mdes_staff) { enumerator.to_a(:staff).first.tap { |p| 
          save_wh(p) } }
        
        let!(:sp_expense) { Factory(:staff_weekly_expense, :staff => sp_staff) }
        let!(:mdes_expense) { enumerator.to_a(:staff_weekly_expenses).first.tap { |p| 
          save_wh(p) } }
        let!(:mdes_record) {
          Factory(:management_task, :staff_weekly_expense => sp_expense, :hours => 5.5)
          enumerator.to_a(:management_tasks).first.tap do |a|
            save_wh(a)
            ManagementTask.destroy_all
            ManagementTask.count.should == 0
          end
        }

        before do
          importer.import(:management_tasks)
        end

        it 'creates a new record' do
          ManagementTask.count.should == 1
        end

        it 'creates a new record with correct hours' do
          ManagementTask.first.hours.should == 5.5
        end 
        
        it 'creates a new record with correct code associations for task type' do
          ManagementTask.first.task_type_code.should == 1
        end
      end        
    end
    
    describe 'conversion for data collection task' do
      describe 'of a completely new record' do
        let!(:sp_staff) { Factory(:valid_staff) }
        let!(:mdes_staff) { enumerator.to_a(:staff).first.tap { |p| 
          save_wh(p) } }
        
        let!(:sp_expense) { Factory(:staff_weekly_expense, :staff => sp_staff) }
        let!(:mdes_expense) { enumerator.to_a(:staff_weekly_expenses).first.tap { |p| 
          save_wh(p) } }
        let!(:mdes_record) {
          Factory(:data_collection_task, :staff_weekly_expense => sp_expense, :hours => 5.5)
          enumerator.to_a(:data_collection_tasks).first.tap do |a|
            save_wh(a)
            DataCollectionTask.destroy_all
            DataCollectionTask.count.should == 0
          end
        }

        before do
          importer.import(:data_collection_tasks)
        end

        it 'creates a new record' do
          DataCollectionTask.count.should == 1
        end
        
        it 'creates a new record with correct hours' do
          DataCollectionTask.first.hours.should == 5.5
        end 
        
        it 'creates a new record with correct code associations for task type' do
          DataCollectionTask.first.task_type_code.should == 1
        end
      end        
    end
    
    describe 'conversion for data collection task' do
      describe 'of a completely new record' do
        let!(:sp_staff) { Factory(:valid_staff) }
        let!(:mdes_staff) { enumerator.to_a(:staff).first.tap { |p| 
          save_wh(p) } }
        
        let!(:sp_expense) { Factory(:staff_weekly_expense, :staff => sp_staff) }
        let!(:mdes_expense) { enumerator.to_a(:staff_weekly_expenses).first.tap { |p| 
          save_wh(p) } }
        let!(:mdes_record) {
          Factory(:data_collection_task, :staff_weekly_expense => sp_expense, :hours => 5.5)
          enumerator.to_a(:data_collection_tasks).first.tap do |a|
            save_wh(a)
            DataCollectionTask.destroy_all
            DataCollectionTask.count.should == 0
          end
        }

        before do
          importer.import(:data_collection_tasks)
        end

        it 'creates a new record' do
          DataCollectionTask.count.should == 1
        end
        
        it 'creates a new record with correct hours' do
          DataCollectionTask.first.hours.should == 5.5
        end 
        
        it 'creates a new record with correct code associations for task type' do
          DataCollectionTask.first.task_type_code.should == 1
        end
      end        
    end
    
    describe 'conversion for outreach event' do
      describe 'of a completely new record' do
        let!(:ncs_area) { Factory(:ncs_area) }
        let!(:ncs_area_ssu) { Factory(:ncs_area_ssu, :ncs_area => ncs_area, :ssu_id => '1234567890') }
        let!(:outreach_segment) { Factory(:outreach_segment, :ncs_area => ncs_area) }

        let!(:mdes_record) {
          Factory(:outreach_event, :outreach_segments => [outreach_segment], :no_of_staff => 2, :cost => 100)
          save_wh(MdesModule::Ssu.new(:sc_id => '20000029', :ssu_id => '1234567890', :ssu_name =>'testing'))
          enumerator.to_a(:outreach_events).first.tap do |a|
            a.outreach_event_id = "event_id_1234567890"
            a.outreach_quantity = 8
            save_wh(a)
            OutreachSegment.destroy_all
            OutreachSegment.count.should == 0
            OutreachEvent.destroy_all
            OutreachEvent.count.should == 0
          end
        }

        before do
          importer.import(:outreach_events)
        end

        it 'creates a new record' do
          OutreachEvent.count.should == 1
        end
        
        it "has correct imported outreach_event_id" do
          OutreachEvent.first.outreach_event_id.should == "event_id_1234567890"
        end
        
        it "map the outreach_event_id to source_id" do
          OutreachEvent.first.source_id.should_not be_nil
          OutreachEvent.first.source_id.should == "event_id_1234567890"
        end
        
        it 'has correct outreach event date' do
          OutreachEvent.first.event_date.to_s.should == "05/12/2012"
        end 
        
        it 'has correct outreach event mode' do
          OutreachEvent.first.mode_code.should == 1
        end
        
        it 'has correct outreach event type' do
          OutreachEvent.first.outreach_type_code.should == 1
        end
        
        it 'has correct outreach event tailored' do
          OutreachEvent.first.tailored_code.should == 1
        end
        
        it 'has correct outreach event language specific' do
          OutreachEvent.first.language_specific_code.should == -4
        end
        
        it 'has correct outreach event race specific' do
          OutreachEvent.first.race_specific_code.should == -4
        end
        
        it 'has correct outreach event culture specific' do
          OutreachEvent.first.culture_specific_code.should == -4
        end
        
        it 'has correct outreach event culture' do
          OutreachEvent.first.culture_code.should == -4
        end
        
        it 'has correct outreach event cost' do
          OutreachEvent.first.cost.should == 100
        end
        
        it 'has correct outreach event no_of_staff' do
          OutreachEvent.first.no_of_staff.should == 2
        end
        
        it 'has correct outreach event evaluation_result' do
          OutreachEvent.first.evaluation_result_code.should == 1
        end
        
        it 'has correct outreach event attendees_quantity' do
          OutreachEvent.first.attendees_quantity.should == 8
        end
        
        it 'has correct outreach segment area mapped to correct ssu' do
          OutreachEvent.first.outreach_segments.first.ncs_area.ncs_area_ssus.first.ssu_id.should == "1234567890"
        end
        
        describe "tsu_id" do
          it "has not create outreach tsu if tsu_id is not set in mdes outreach" do
            OutreachEvent.first.outreach_tsus.size.should == 0
          end
          
          describe 'has correct outreach tsu ' do
            before do
              Factory(:ncs_tsu, :tsu_id => 'tsu_123')
              save_wh(MdesModule::Tsu.new(:sc_id => '20000029', :tsu_id => 'tsu_123', :tsu_name =>'tsu_name_123'))
              mdes_record.tsu_id = "tsu_123"
              save_wh(mdes_record)
              importer.import(:outreach_events)
            end
            
            it "number" do
              OutreachEvent.first.outreach_tsus.size.should == 1
            end
            
            it "mapped to ncs_tsu" do
              OutreachEvent.first.ncs_tsus.first.tsu_id.should == "tsu_123"
            end
          end
        end
      end        
    end
    
    describe 'conversion for outreach race' do
      describe 'of a completely new record' do
        let!(:ncs_area) { Factory(:ncs_area) }
        let!(:ncs_area_ssu) { Factory(:ncs_area_ssu, :ncs_area => ncs_area, :ssu_id => '1234567890') }
        let!(:outreach_segment) { Factory(:outreach_segment, :ncs_area => ncs_area) }
        
        let!(:sp_outreach) {Factory(:outreach_event, :outreach_segments => [outreach_segment], :outreach_event_id => "event_id_1234567890")}
        let!(:mdes_outreach) {
          save_wh(MdesModule::Ssu.new(:sc_id => '20000029', :ssu_id => '1234567890', :ssu_name =>'testing'))
          enumerator.to_a(:outreach_events).first.tap { |p| 
            p.outreach_event_id = "event_id_1234567890"
            save_wh(p) } 
        }
        let!(:mdes_record) {
          Factory(:outreach_race, :outreach_event => sp_outreach)
          enumerator.to_a(:outreach_races).first.tap do |a|
            a.outreach_event_id = mdes_outreach.outreach_event_id
            save_wh(a)
            OutreachRace.destroy_all
            OutreachRace.count.should == 0
          end
        }
        
        before do
          importer.import(:outreach_races)
        end

        it 'creates a new record' do
          OutreachRace.count.should == 1
        end
        
        it "map the outreach_race_id to source_id" do
          OutreachRace.first.source_id.should_not be_nil
          OutreachRace.first.source_id.should == OutreachRace.first.outreach_race_id
        end
        
        it 'has correct outreach race code' do
          OutreachRace.first.race_code.should == 1
        end 
        it 'creates a new outreach race record with correct outreach entity associations' do
          OutreachRace.first.outreach_event.id. == sp_outreach.id
        end
      end        
    end
    
    describe 'conversion for outreach target' do
      describe 'of a completely new record' do
        let!(:ncs_area) { Factory(:ncs_area) }
        let!(:ncs_area_ssu) { Factory(:ncs_area_ssu, :ncs_area => ncs_area, :ssu_id => '1234567890') }
        let!(:outreach_segment) { Factory(:outreach_segment, :ncs_area => ncs_area) }
        
        let!(:sp_outreach) {Factory(:outreach_event, :outreach_segments => [outreach_segment], :outreach_event_id => "event_id_1234567890")}
        let!(:mdes_outreach) {
          save_wh(MdesModule::Ssu.new(:sc_id => '20000029', :ssu_id => '1234567890', :ssu_name =>'testing'))
          enumerator.to_a(:outreach_events).first.tap { |p| 
            p.outreach_event_id = "event_id_1234567890"
            save_wh(p) } 
        }
        let!(:mdes_record) {
          Factory(:outreach_target, :outreach_event => sp_outreach)
          enumerator.to_a(:outreach_targets).first.tap do |a|
            a.outreach_event_id = mdes_outreach.outreach_event_id
            save_wh(a)
            OutreachTarget.destroy_all
            OutreachTarget.count.should == 0
          end
        }
        
        before do
          importer.import(:outreach_targets)
        end

        it 'creates a new record' do
          OutreachTarget.count.should == 1
        end
        
        it "map the outreach_target_id to source_id" do
          OutreachTarget.first.source_id.should_not be_nil
          OutreachTarget.first.source_id.should == OutreachTarget.first.outreach_target_id
        end
        
        it 'has correct outreach target code' do
          OutreachTarget.first.target_code.should == 10
        end 
        it 'creates a new outreach target record with correct outreach entity associations' do
          OutreachTarget.first.outreach_event.id. == sp_outreach.id
        end
      end        
    end
    
    describe 'conversion for outreach evaluation' do
      describe 'of a completely new record' do
        let!(:ncs_area) { Factory(:ncs_area) }
        let!(:ncs_area_ssu) { Factory(:ncs_area_ssu, :ncs_area => ncs_area, :ssu_id => '1234567890') }
        let!(:outreach_segment) { Factory(:outreach_segment, :ncs_area => ncs_area) }
        
        let!(:sp_outreach) {Factory(:outreach_event, :outreach_segments => [outreach_segment], :outreach_event_id => "event_id_1234567890")}
        let!(:mdes_outreach) {
          save_wh(MdesModule::Ssu.new(:sc_id => '20000029', :ssu_id => '1234567890', :ssu_name =>'testing'))
          enumerator.to_a(:outreach_events).first.tap { |p| 
            p.outreach_event_id = "event_id_1234567890"
            save_wh(p) } 
        }
        let!(:mdes_record) {
          Factory(:outreach_evaluation, :outreach_event => sp_outreach)
          enumerator.to_a(:outreach_evaluations).first.tap do |a|
            a.outreach_event_id = mdes_outreach.outreach_event_id
            save_wh(a)
            OutreachEvaluation.destroy_all
            OutreachEvaluation.count.should == 0
          end
        }
        
        before do
          importer.import(:outreach_evaluations)
        end

        it 'creates a new record' do
          OutreachEvaluation.count.should == 1
        end
        
        it "map the outreach_event_eval_id to source_id" do
          OutreachEvaluation.first.source_id.should_not be_nil
          OutreachEvaluation.first.source_id.should == OutreachEvaluation.first.outreach_event_eval_id
        end
        
        it 'has correct outreach evaluation code' do
          OutreachEvaluation.first.evaluation_code.should == 1
        end 
        it 'creates a new outreach evaluation record with correct outreach entity associations' do
          OutreachEvaluation.first.outreach_event.id.should == sp_outreach.id
        end
      end        
    end
    
    describe 'conversion for outreach staff' do
      describe 'of a completely new record' do
        let!(:ncs_area) { Factory(:ncs_area) }
        let!(:ncs_area_ssu) { Factory(:ncs_area_ssu, :ncs_area => ncs_area, :ssu_id => '1234567890') }
        let!(:outreach_segment) { Factory(:outreach_segment, :ncs_area => ncs_area) }
        
        let!(:sp_outreach) {Factory(:outreach_event, :outreach_segments => [outreach_segment], :outreach_event_id => "event_id_1234567890")}
        let!(:mdes_outreach) {
          save_wh(MdesModule::Ssu.new(:sc_id => '20000029', :ssu_id => '1234567890', :ssu_name =>'testing'))
          enumerator.to_a(:outreach_events).first.tap { |p| 
            p.outreach_event_id = "event_id_1234567890"
            save_wh(p) } 
        }
        
        let!(:sp_staff) { Factory(:valid_staff) }
        let!(:mdes_staff) { enumerator.to_a(:staff).first.tap { |p| 
          save_wh(p) } }
          
        let!(:mdes_record) {
          Factory(:outreach_staff_member, :outreach_event => sp_outreach, :staff => sp_staff)
          enumerator.to_a(:outreach_staff_members).first.tap do |a|
            a.outreach_event_id = mdes_outreach.outreach_event_id
            save_wh(a)
            OutreachStaffMember.destroy_all
            OutreachStaffMember.count.should == 0
          end
        }
        
        before do
          importer.import(:outreach_staff_members)
        end

        it 'creates a new record' do
          OutreachStaffMember.count.should == 1
        end
        
        it "map the outreach_event_staff_id to source_id" do
          OutreachStaffMember.first.source_id.should_not be_nil
          OutreachStaffMember.first.source_id.should == OutreachStaffMember.first.outreach_event_staff_id
        end
        
        it 'has correct outreach event mapping' do
          OutreachStaffMember.first.outreach_event.id.should == sp_outreach.id
        end 
        
        it 'has correct staff mapping' do
          OutreachStaffMember.first.staff.staff_id == sp_staff.id
        end
      end        
    end
    
    describe 'conversion for outreach languages' do
      describe 'of a completely new record' do
        let!(:ncs_area) { Factory(:ncs_area) }
        let!(:ncs_area_ssu) { Factory(:ncs_area_ssu, :ncs_area => ncs_area, :ssu_id => '1234567890') }
        let!(:outreach_segment) { Factory(:outreach_segment, :ncs_area => ncs_area) }
        
        let!(:sp_outreach) {Factory(:outreach_event, :outreach_segments => [outreach_segment], :outreach_event_id => "event_id_1234567890")}
        let!(:mdes_outreach) {
          save_wh(MdesModule::Ssu.new(:sc_id => '20000029', :ssu_id => '1234567890', :ssu_name =>'testing'))
          enumerator.to_a(:outreach_events).first.tap { |p| 
            p.outreach_lang_oth = "Babylonian"
            p.outreach_event_id = "event_id_1234567890"
            save_wh(p) } 
        }

        let!(:mdes_record) {
          Factory(:outreach_language,
            :outreach_event => sp_outreach)
          enumerator.to_a(:outreach_languages).first.tap do |a|
            a.outreach_event_id = mdes_outreach.outreach_event_id
            save_wh(a)
            OutreachLanguage.destroy_all
            OutreachLanguage.count.should == 0
          end
        }
        
        before do
          importer.import(:outreach_languages)
        end

        it 'creates a new record' do
          OutreachLanguage.count.should == 1
        end
        
        it "map the outreach_lang2_id to source_id" do
          OutreachLanguage.first.outreach_lang2_id.should_not be_nil
          OutreachLanguage.first.outreach_lang2_id.should == OutreachLanguage.first.outreach_lang2_id
        end
        
        it 'has correct outreach language code mapping' do
          OutreachLanguage.first.language_code.should == 1
        end 
        
        it 'has correct outreach language other mapping from mdes outreach event' do
          OutreachLanguage.first.language_other.should == "Babylonian"
        end

      end        
    end

  end
end
