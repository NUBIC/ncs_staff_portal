require 'spec_helper'

require 'ncs_navigator/staff_portal/warehouse'

require File.expand_path('../importer_warehouse_setup', __FILE__)

module NcsNavigator::StaffPortal::Warehouse
  describe 'Importer', :clean_with_truncation, :warehouse do

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
        Importer.automatic_producers.size.should == 12
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

          it 'updates that scalar field in NCS Navigator Ops' do
            StaffCertTraining.first.frequency.should == "10 Times"
          end

          it 'does not add a new record' do
            StaffCertTraining.count.should == 1
          end
        end

        describe 'when an entity association is changed' do
          let!(:sp_second_staff) { Factory(:valid_staff, :username => "new", :email => "new@test.com", :zipcode => '33333') }
          let!(:mdes_second_staff) { enumerator.to_a(:staff).second.tap { |p| save_wh(p) } }

          before do
            mdes_record.staff_id = sp_second_staff.public_id
            save_wh(mdes_record)

            importer.import(:staff_cert_trainings)
          end

          it 'updates the association to the core object' do
            StaffCertTraining.first.staff.zipcode.should == '33333'
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
          Staff.first.zipcode.should == '92131'
        end

        it 'creates a new record with age range set' do
          Staff.first.age_group_code.should == 4
        end

        it 'creates a new record with correct code associations' do
          Staff.first.gender_code.should == 2
        end

        it 'makes staff as external user to the application by default' do
          Staff.first.external.should == true
        end

        it 'makes staff notify (used for weekly reminder e-mail) to set false by default' do
          Staff.first.notify.should == false
        end

        it 'set staff inactive date as of imported date which might be always today date' do
          Staff.first.ncs_inactive_date.should == Date.today
        end
      end

      describe 'of a completely new record with race value is other and race_other is null' do
        let!(:sp_staff) { Factory(:valid_staff) }
        let!(:mdes_staff) { enumerator.to_a(:staff).first.tap { |p|
          p.staff_race = "-5"
          p.staff_race_oth = nil
          save_wh(p)
          Staff.destroy_all
          Staff.count.should == 0 } }

        before do
          importer.import(:staff)
        end

        it 'creates a new record' do
          Staff.count.should == 1
        end

        it 'creates a new record with race_other value filled by importer' do
          Staff.first.race_other.should == "Missing in Error - Other value"
        end
      end

      describe 'of a completely new record with staff_type value is other and staff_type_other is null' do
        let!(:sp_staff) { Factory(:valid_staff) }
        let!(:mdes_staff) { enumerator.to_a(:staff).first.tap { |p|
          p.staff_type = "-5"
          p.staff_type_oth = nil
          save_wh(p)
          Staff.destroy_all
          Staff.count.should == 0 } }

        before do
          importer.import(:staff)
        end

        it 'creates a new record' do
          Staff.count.should == 1
        end

        it 'creates a new record with race_other value filled by importer' do
          Staff.first.staff_type_other.should == "Missing in Error - Other value"
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

      describe 'of a completely new record with language value is other and lang_other is null' do
        let(:other_code) { Factory(:ncs_code, :list_name => "LANGUAGE_CL2", :display_text => "Other", :local_code => -5) }
        let!(:sp_staff) { Factory(:valid_staff) }
        let!(:mdes_staff) { enumerator.to_a(:staff).first.tap { |p|
          save_wh(p) } }

        let!(:mdes_record) {
          Factory(:staff_language, :lang => other_code, :lang_other => 'temp', :staff => sp_staff)
          enumerator.to_a(:staff_languages_other).first.tap do |a|
            a.staff_lang_oth = nil
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

        it 'creates a new record with lang_other value filled by importer' do
          StaffLanguage.first.lang_other.should == "Missing in Error - Other value"
        end
      end
    end

    describe 'conversion for staff_cert_trainings' do
      describe 'of a completely new record' do
        let!(:sp_staff) { Factory(:valid_staff) }
        let!(:mdes_staff) { enumerator.to_a(:staff).first.tap { |p|
          save_wh(p) } }

        let!(:mdes_record) {
          Factory(:staff_cert_training, :staff => sp_staff, :expiration_date => Date.new(2012, 05, 12))
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

        it 'has correct training type code' do
          StaffCertTraining.first.certificate_type_code.should == 1
        end

        it 'has correct background check' do
          StaffCertTraining.first.background_check_code.should == 1
        end

        it 'has correct expiration date' do
          StaffCertTraining.first.expiration_date.should == Date.new(2012, 05, 12)
        end
      end
    end

    describe 'conversion for staff weekly expense' do
      describe 'of a completely new record' do
        let!(:sp_staff) { Factory(:valid_staff) }
        let!(:mdes_staff) { enumerator.to_a(:staff).first.tap { |p|
          save_wh(p) } }

        let!(:mdes_record) {
          Factory(:staff_weekly_expense, :staff => sp_staff, :rate => 32.50, :hours => 25, :expenses => 200, :miles => 15.7)
          enumerator.to_a(:staff_weekly_expenses).first.tap do |a|
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

        it 'records staff pay correctly' do
          StaffWeeklyExpense.first.rate.should == 32.50
        end

        it "records weekly hours correctly" do
           StaffWeeklyExpense.first.hours.should == 25
        end

        it "records weekly expenses correctly" do
           StaffWeeklyExpense.first.expenses.should == 200
        end

        it "records weekly miles correctly" do
           StaffWeeklyExpense.first.miles.should == 15.7
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

      describe 'of a completely new record with task_type value is other and task_type_other value is null' do
        let(:other_code) { Factory(:ncs_code, :list_name => "STUDY_MNGMNT_TSK_TYPE_CL1", :display_text => "Other", :local_code => -5) }
        let!(:sp_staff) { Factory(:valid_staff) }
        let!(:mdes_staff) { enumerator.to_a(:staff).first.tap { |p|
          save_wh(p) } }

        let!(:sp_expense) { Factory(:staff_weekly_expense, :staff => sp_staff) }
        let!(:mdes_expense) { enumerator.to_a(:staff_weekly_expenses).first.tap { |p|
          save_wh(p) } }
        let!(:mdes_record) {
          Factory(:management_task, :task_type => other_code, :task_type_other => 'temp', :staff_weekly_expense => sp_expense)
          enumerator.to_a(:management_tasks).first.tap do |a|
            a.mgmt_task_type_oth = nil
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

        it 'creates a new record with task_type_other value filled by importer' do
          ManagementTask.first.task_type_other.should == "Missing in Error - Other value"
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

      describe 'of a completely new record with task_type value is other and task_type_other value is null' do
        let(:other_code) { Factory(:ncs_code, :list_name => "STUDY_DATA_CLLCTN_TSK_TYPE_CL1", :display_text => "Other", :local_code => -5) }
        let!(:sp_staff) { Factory(:valid_staff) }
        let!(:mdes_staff) { enumerator.to_a(:staff).first.tap { |p|
          save_wh(p) } }

        let!(:sp_expense) { Factory(:staff_weekly_expense, :staff => sp_staff) }
        let!(:mdes_expense) { enumerator.to_a(:staff_weekly_expenses).first.tap { |p|
          save_wh(p) } }
        let!(:mdes_record) {
          Factory(:data_collection_task, :task_type => other_code, :task_type_other => 'temp', :staff_weekly_expense => sp_expense)
          enumerator.to_a(:data_collection_tasks).first.tap do |a|
            a.data_coll_task_type_oth = nil
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

        it 'creates a new record with task_type_other value filled by importer' do
          DataCollectionTask.first.task_type_other.should == "Missing in Error - Other value"
        end
      end
    end

    describe 'conversion for outreach event' do
      describe 'of a completely new record' do
        let!(:ncs_ssu) { Factory(:ncs_ssu, :ssu_id => '1234567890') }
        let!(:outreach_segment) { Factory(:outreach_segment, :ncs_ssu => ncs_ssu) }

        let!(:mdes_record) {
          Factory(:outreach_event, :outreach_segments => [outreach_segment], :no_of_staff => 2, :cost => 100)
          save_wh(wh_config.model(:Ssu).new(:sc_id => '20000029', :ssu_id => '1234567890', :ssu_name =>'testing'))
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
          OutreachEvent.first.event_date.to_s.should == "2012-05-12"
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
          OutreachEvent.first.outreach_segments.first.ncs_ssu.ssu_id.should == "1234567890"
        end

        it "has not create outreach segment tsu if tsu_id is not set in mdes outreach" do
           OutreachEvent.first.outreach_segments.first.ncs_tsu.should be_nil
        end
      end

      describe 'if ncs_ssu with outreach ssu_id is not found' do
        let!(:ncs_ssu) { Factory(:ncs_ssu, :ssu_id => '1234567890') }
        let!(:outreach_segment) { Factory(:outreach_segment, :ncs_ssu => ncs_ssu) }

        let!(:mdes_record) {
          Factory(:outreach_event, :outreach_segments => [outreach_segment])
          save_wh(wh_config.model(:Ssu).new(:sc_id => '20000029', :ssu_id => '1234567890', :ssu_name =>'testing'))
          enumerator.to_a(:outreach_events).first.tap do |a|
            a.outreach_event_id = "event_id_1234567890"
            save_wh(a)
            NcsSsu.destroy_all
            NcsSsu.count.should == 0
            OutreachSegment.destroy_all
            OutreachSegment.count.should == 0
            OutreachEvent.destroy_all
            OutreachEvent.count.should == 0
          end
        }

        it "will not create outreach segment" do
           expect { importer.import(:outreach_events) }.should raise_error
        end
      end

      describe "for other coded value to 'other' and corresponding other value is null" do
        let(:other_mode_code) { Factory(:ncs_code, :list_name => "OUTREACH_MODE_CL1", :display_text => "Other", :local_code => -5) }
        let(:other_type_code) { Factory(:ncs_code, :list_name => "OUTREACH_TYPE_CL1", :display_text => "Other", :local_code => -5) }
        let(:other_culture_code) { Factory(:ncs_code, :list_name => "CULTURE_CL1", :display_text => "Other", :local_code => -5) }
        let!(:ncs_ssu) { Factory(:ncs_ssu, :ssu_id => '1234567890') }
        let!(:outreach_segment) { Factory(:outreach_segment, :ncs_ssu => ncs_ssu) }

        let!(:mdes_record) {
          Factory(:outreach_event, :outreach_segments => [outreach_segment],
                  :mode => other_mode_code, :mode_other => "temp",
                  :outreach_type => other_type_code, :outreach_type_other => "temp",
                  :culture => other_culture_code, :culture_other => "temp")
          save_wh(wh_config.model(:Ssu).new(:sc_id => '20000029', :ssu_id => '1234567890', :ssu_name =>'testing'))
          enumerator.to_a(:outreach_events).first.tap do |a|
            a.outreach_event_id = "event_id_1234567890"
            a.outreach_mode_oth = nil
            a.outreach_type_oth = nil
            a.outreach_culture_oth = nil
            save_wh(a)
            OutreachEvent.destroy_all
            OutreachEvent.count.should == 0
          end
        }

        before do
          importer.import(:outreach_events)
        end

        it 'creates a new record with mode_other value filled by importer' do
           OutreachEvent.first.mode_other.should == "Missing in Error - Other value"
        end

        it 'creates a new record with outreach_type_other value filled by importer' do
           OutreachEvent.first.outreach_type_other.should == "Missing in Error - Other value"
        end

        it 'creates a new record with culture_other value filled by importer' do
           OutreachEvent.first.culture_other.should == "Missing in Error - Other value"
        end
      end

      describe 'for tsu_id is set in mdes outreach' do
        let!(:ncs_ssu) { Factory(:ncs_ssu, :ssu_id => '1234567890') }
        let!(:ncs_tsu) { Factory(:ncs_tsu, :tsu_id => 'tsu_123') }
        let!(:outreach_segment) { Factory(:outreach_segment, :ncs_ssu => ncs_ssu) }

        let!(:mdes_record) {
          Factory(:outreach_event, :outreach_segments => [outreach_segment])
          save_wh(wh_config.model(:Ssu).new(:sc_id => '20000029', :ssu_id => '1234567890', :ssu_name =>'testing'))
          save_wh(wh_config.model(:Tsu).new(:sc_id => '20000029', :tsu_id => 'tsu_123', :tsu_name =>'tsu_123'))
          enumerator.to_a(:outreach_events).first.tap do |a|
            a.outreach_event_id = "event_id_1234567890"
            a.tsu_id = 'tsu_123'
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

        it "outreach segment tsu is not null" do
           OutreachEvent.first.outreach_segments.first.ncs_tsu.should_not be_nil
        end

        it "outreach segment tsu has correct tsu_id" do
           OutreachEvent.first.outreach_segments.first.ncs_tsu.tsu_id.should == "tsu_123"
        end
      end
    end

    describe 'conversion for outreach race' do
      describe 'of a completely new record' do
        let!(:ncs_ssu) { Factory(:ncs_ssu, :ssu_id => '1234567890') }
        let!(:outreach_segment) { Factory(:outreach_segment, :ncs_ssu => ncs_ssu) }

        let!(:sp_outreach) {Factory(:outreach_event, :outreach_segments => [outreach_segment], :outreach_event_id => "event_id_1234567890")}
        let!(:mdes_outreach) {
          save_wh(wh_config.model(:Ssu).new(:sc_id => '20000029', :ssu_id => '1234567890', :ssu_name =>'testing'))
          enumerator.to_a(:outreach_events).first.tap { |p|
            p.outreach_event_id = "event_id_1234567890"
            save_wh(p) }
        }
        let!(:mdes_record) {
          Factory(:outreach_race, :outreach_event => sp_outreach,
          :race => Factory(:ncs_code, :list_name => "RACE_CL3", :display_text => "Other", :local_code => -5),
          :race_other => "temp")
          enumerator.to_a(:outreach_races).first.tap do |a|
            a.outreach_event_id = mdes_outreach.outreach_event_id
            a.outreach_race_oth = nil
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
          OutreachRace.first.race_code.should == -5
        end

        it 'has race_other value filled by importer' do
           OutreachRace.first.race_other.should == "Missing in Error - Other value"
        end

        it 'creates a new outreach race record with correct outreach entity associations' do
          OutreachRace.first.outreach_event.id. == sp_outreach.id
        end
      end
    end

    describe 'conversion for outreach target' do
      describe 'of a completely new record' do
        let!(:ncs_ssu) { Factory(:ncs_ssu, :ssu_id => '1234567890') }
        let!(:outreach_segment) { Factory(:outreach_segment, :ncs_ssu => ncs_ssu) }

        let!(:sp_outreach) {Factory(:outreach_event, :outreach_segments => [outreach_segment], :outreach_event_id => "event_id_1234567890")}
        let!(:mdes_outreach) {
          save_wh(wh_config.model(:Ssu).new(:sc_id => '20000029', :ssu_id => '1234567890', :ssu_name =>'testing'))
          enumerator.to_a(:outreach_events).first.tap { |p|
            p.outreach_event_id = "event_id_1234567890"
            save_wh(p) }
        }
        let!(:mdes_record) {
          Factory(:outreach_target, :outreach_event => sp_outreach,
          :target => Factory(:ncs_code, :list_name => "OUTREACH_TARGET_CL1", :display_text => "Other", :local_code => -5),
          :target_other => "temp")
          enumerator.to_a(:outreach_targets).first.tap do |a|
            a.outreach_event_id = mdes_outreach.outreach_event_id
            a.outreach_target_ms_oth = nil
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
          OutreachTarget.first.target_code.should == -5
        end

        it 'has target_other value filled by importer' do
           OutreachTarget.first.target_other.should == "Missing in Error - Other value"
        end

        it 'creates a new outreach target record with correct outreach entity associations' do
          OutreachTarget.first.outreach_event.id. == sp_outreach.id
        end
      end
    end

    describe 'conversion for outreach evaluation' do
      describe 'of a completely new record' do
        let!(:ncs_ssu) { Factory(:ncs_ssu, :ssu_id => '1234567890') }
        let!(:outreach_segment) { Factory(:outreach_segment, :ncs_ssu => ncs_ssu) }

        let!(:sp_outreach) { Factory(:outreach_event, :outreach_segments => [outreach_segment], :outreach_event_id => "event_id_1234567890") }
        let!(:mdes_outreach) {
          save_wh(wh_config.model(:Ssu).new(:sc_id => '20000029', :ssu_id => '1234567890', :ssu_name =>'testing'))
          enumerator.to_a(:outreach_events).first.tap { |p|
            p.outreach_event_id = "event_id_1234567890"
            save_wh(p) }
        }
        let!(:mdes_record) {
          Factory(:outreach_evaluation, :outreach_event => sp_outreach,
          :evaluation => Factory(:ncs_code, :list_name => "OUTREACH_EVAL_CL1", :display_text => "Other", :local_code => -5),
          :evaluation_other => "temp"
          )
          enumerator.to_a(:outreach_evaluations).first.tap do |a|
            a.outreach_event_id = mdes_outreach.outreach_event_id
            a.outreach_eval_oth = nil
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
          OutreachEvaluation.first.evaluation_code.should == -5
        end

        it 'has evaluation_other value filled by importer' do
           OutreachEvaluation.first.evaluation_other.should == "Missing in Error - Other value"
        end

        it 'creates a new outreach evaluation record with correct outreach entity associations' do
          OutreachEvaluation.first.outreach_event.id.should == sp_outreach.id
        end
      end
    end

    describe 'conversion for outreach staff' do
      describe 'of a completely new record' do
        let!(:ncs_ssu) { Factory(:ncs_ssu, :ssu_id => '1234567890') }
        let!(:outreach_segment) { Factory(:outreach_segment, :ncs_ssu => ncs_ssu) }

        let!(:sp_outreach) { Factory(:outreach_event, :outreach_segments => [outreach_segment], :outreach_event_id => "event_id_1234567890") }
        let!(:mdes_outreach) {
          save_wh(wh_config.model(:Ssu).new(:sc_id => '20000029', :ssu_id => '1234567890', :ssu_name =>'testing'))
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
        let!(:ncs_ssu) { Factory(:ncs_ssu, :ssu_id => '1234567890') }
        let!(:outreach_segment) { Factory(:outreach_segment, :ncs_ssu => ncs_ssu) }

        let!(:sp_outreach) {Factory(:outreach_event, :outreach_segments => [outreach_segment], :outreach_event_id => "event_id_1234567890")}
        let!(:mdes_outreach) {
          save_wh(wh_config.model(:Ssu).new(:sc_id => '20000029', :ssu_id => '1234567890', :ssu_name =>'testing'))
          enumerator.to_a(:outreach_events).first.tap { |p|
            p.outreach_event_id = "event_id_1234567890"
            save_wh(p) }
        }

        let!(:mdes_record) {
          Factory(:outreach_language, :outreach_event => sp_outreach)
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
          OutreachLanguage.first.language_other.should be_nil
        end

      end
    end

  end
end
