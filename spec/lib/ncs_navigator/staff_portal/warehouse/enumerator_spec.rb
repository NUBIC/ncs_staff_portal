require 'spec_helper'

module NcsNavigator::StaffPortal::Warehouse
  describe Enumerator, :clean_with_truncation, :slow do
    MdesModule = NcsNavigator::Warehouse::Models::TwoPointZero

    let(:wh_config) {
      NcsNavigator::Warehouse::Configuration.new.tap do |config|
        config.log_file = File.join(Rails.root, 'log/wh.log')
        config.set_up_logs
        config.output_level = :quiet
      end
    }

    let(:bcdatabase_config) {
      if Rails.env == 'ci'
        { :group => 'public_ci_postgresql9' }
      else
        { :name => 'ncs_staff_portal_test' }
      end
    }

    let(:enumerator) {
      Enumerator.new(wh_config, :bcdatabase => bcdatabase_config)
    }
    let(:producer_names) { [] }
    let(:results) { enumerator.to_a(*producer_names) }

    it 'can be created' do
      Enumerator.create_transformer(wh_config).should respond_to(:transform)
    end

    it 'uses the correct bcdatabase config' do
      Enumerator.bcdatabase[:name].should == 'ncs_staff_portal'
    end

    shared_context 'mapping test' do
      before do
        # ignore unused so we can see the mapping failures
        Enumerator.on_unused_columns :ignore
      end

      after do
        Enumerator.on_unused_columns :fail
      end

      def self.ncs_code(code)
        Factory(:ncs_code, :local_code => code)
      end

      def self.verify_mapping(sp_field, sp_value, wh_field, wh_value=nil)
        wh_value ||= sp_value
        it "maps #{sp_field} to #{wh_field}" do
          sp_model.last.tap { |p| p.send("#{sp_field}=", sp_value) }.save!
          results.last.send(wh_field).should == wh_value
        end
      end
    end

    def record_should_be_valid(wh_record)
      if wh_record.respond_to?(:psu_id=)
        wh_record.psu_id = '20000030'
      end
      wh_record.valid?
      wh_record.errors.to_a.should == []
    end

    shared_examples 'one-to-one valid' do
      it 'produces a single valid warehouse record from a valid staff portal record' do
        sp_record.should be_valid
        record_should_be_valid(results.first)
      end
    end

    shared_examples 'staff associated' do
      it 'produces no records for an incomplete staff member' do
        staff.update_attribute(:zipcode, nil)
        results.size.should == 0
      end
    end

    describe 'for Staff' do
      let(:producer_names) { [:staff] }
      let(:sp_model) { Staff }
      let!(:sp_record) { Factory(:valid_staff) }

      it 'excludes records which have been initialized but not updated' do
        Factory(:staff, :validate_create => 'true', :zipcode => nil)

        results.collect(&:staff_zip).should == %w(92131)
      end

      include_examples 'one-to-one valid'

      context do
        include_context 'mapping test'

        [
          # prefix breaks default behavior
          [:staff_id, 'Eleventy', :staff_id],
          [:comment, 'Short', :staff_comment],
          [:zipcode, '00101', :staff_zip],
          [:experience, ncs_code(1), :staff_exp, '1']
        ].each { |args| verify_mapping(*args) }

        describe 'year of birth' do
          it 'is extracted when set' do
            results.last.staff_yob.should == '1977'
          end

          it 'is blank when unknown' do
            sp_record.update_attribute(:birth_date, nil)
            results.last.staff_yob.should be_nil
          end
        end

        describe 'age range' do
          [
            [16, 1], [23, 2], [34, 3], [40, 4], [46, 5], [63, 6], [72, 7]
          ].each do |age, expected_code|
            it "is #{expected_code} when the staff member is #{age}" do
              sp_record.update_attribute(:birth_date, Time.now - age.years)
              results.last.staff_age_range.should == expected_code.to_s
            end
          end

          it 'is blank when unknown' do
            sp_record.update_attribute(:birth_date, nil)
            results.last.staff_age_range.should be_nil
          end
        end
      end
    end

    describe 'for StaffLanguage' do
      let(:sp_model) { StaffLanguage }
      let(:other_code) { Factory(:ncs_code, :list_name => 'LANGUAGE_CL2', :local_code => '-5') }
      let(:staff) { Factory(:valid_staff) }

      context 'from code list' do
        let(:producer_names) { [:staff_languages] }
        let!(:sp_record) { Factory(:staff_language, :staff => staff) }

        it 'uses the public ID for staff' do
          results.last.staff_id.should == staff.staff_id
        end

        it 'generates one WH record for each language entry' do
          results.size.should == 1
        end

        it 'ignores "other"' do
          Factory(:staff_language, :lang => other_code, :lang_other => 'Esperanto', :staff => staff)

          results.size.should == 1
        end

        include_examples 'staff associated'
        include_examples 'one-to-one valid'
      end

      context 'other' do
        let(:producer_names) { [:staff_languages_other] }

        before do
          Factory(:staff_language, :lang => other_code, :lang_other => 'Esperanto', :staff => staff,
            :staff_language_id => 'E')
          Factory(:staff_language, :lang => other_code, :lang_other => 'Aramaic', :staff => staff,
            :staff_language_id => 'A')
        end

        it 'uses the public ID for staff' do
          results.last.staff_id.should == staff.staff_id
        end

        include_examples 'staff associated'

        it 'ignores coded entries' do
          Factory(:staff_language, :staff => staff)

          results.size.should == 1
        end

        it 'aggregates multiple "other" languages into one WH other entry' do
          # Intentionally an array with one string
          results.collect(&:staff_lang_oth).should == ['Esperanto,Aramaic']
        end

        it 'uses the lexically earliest staff_language_id' do
          results.collect(&:staff_language_id).should == ['A']
        end

        it 'includes the other code' do
          results.collect(&:staff_lang).should == ['-5']
        end

        it 'aggregates within a single staff member only' do
          Factory(:staff_language, :lang => other_code, :lang_other => 'Gujarati')

          results.collect(&:staff_lang_oth).sort.should == ['Esperanto,Aramaic', 'Gujarati']
        end
      end
    end

    describe 'for StaffCertTraining' do
      let!(:sp_record) { Factory(:staff_cert_training) }
      let(:sp_model) { StaffCertTraining }

      let(:producer_names) { [:staff_cert_trainings] }

      before do
        pending '#1638'
      end

      it 'uses the public ID for staff' do
        results.first.staff_id.should == Staff.first.staff_id
      end

      it 'generates one WH record per SP record' do
        results.size.should == 1
      end

      include_examples 'one-to-one valid'
      include_examples 'staff associated'

      context do
        include_context 'mapping test'

        [
          [:certificate_type, ncs_code(7), :cert_train_type, '7'],
          [:complete, ncs_code(2), :cert_completed, '2'],
          [:background_check, ncs_code(6), :staff_bgcheck_lvl, '6'],
          [:frequency, 4, :cert_type_frequency, '4'],
          [:cert_date, Date.new(2011, 3, 2), :cert_date, '2011-03-02'],
          [:expiration_date, Date.new(2014, 3, 2), :cert_type_exp_date, '2014-03-02'],
          [:comment, 'Not important', :cert_comment],
        ].each { |args| verify_mapping(*args) }
      end
    end

    describe 'staff weekly expenses' do
      let(:staff) { Factory(:valid_staff) }
      let!(:sp_record) { Factory(:staff_weekly_expense, :staff => staff) }
      let(:sp_model) { StaffWeeklyExpense }

      let(:producer_names) { [:staff_weekly_expenses] }

      it 'uses the public ID for staff' do
        results.first.staff_id.should == Staff.first.staff_id
      end

      it 'uses its own public ID' do
        results.first.weekly_exp_id.should == sp_record.weekly_exp_id
      end

      include_examples 'one-to-one valid'
      include_examples 'staff associated'

      context do
        include_examples 'mapping test'

        [
          [:week_start_date, Date.new(2011, 4, 8), :week_start_date, '2011-04-08'],
          [:comment, 'Slow week', :weekly_expenses_comment],
          [:rate, '23.4', :staff_pay]
        ].each { |args| verify_mapping(*args) }
      end

      shared_examples 'summed attributes' do
        include_context 'mapping test'

        it 'produces one expense record for many tasks' do
          results.size.should == 1
        end

        it 'produces separate WH records for separate SP records' do
          task2.update_attribute(:staff_weekly_expense, Factory(:staff_weekly_expense))
          results.size.should == 2
        end

        describe 'hours' do
          it 'sums across all tasks' do
            task1.update_attributes(:hours => '16.02')
            task2.update_attributes(:hours => '90.00')

            results.first.staff_hours.should == '106.02'
          end

          it 'uses 0.00 if there are no hours' do
            results.first.staff_hours.should == '0.0'
          end
        end

        describe 'expenses' do
          it 'sums across all tasks' do
            task1.update_attributes(:expenses =>  '9.99')
            task2.update_attributes(:expenses => '10.08')

            results.first.staff_expenses.should == '20.07'
          end

          it 'uses 0.00 if there are no expenses' do
            results.first.staff_expenses.should == '0.0'
          end
        end

        describe 'miles' do
          it 'sums across all tasks' do
            task1.update_attributes(:miles =>  '52.02')
            task2.update_attributes(:miles => '150.21')

            results.first.staff_miles.should == '202.23'
          end

          it 'uses 0.00 if there are no miles' do
            results.first.staff_miles.should == '0.0'
          end
        end
      end

      describe 'with management tasks' do
        let!(:task1) { Factory(:management_task, :staff_weekly_expense => sp_record) }
        let!(:task2) { Factory(:management_task, :staff_weekly_expense => sp_record) }

        include_examples 'summed attributes'
      end

      describe 'with data collection tasks' do
        let!(:task1) { Factory(:data_collection_task, :staff_weekly_expense => sp_record) }
        let!(:task2) { Factory(:data_collection_task, :staff_weekly_expense => sp_record) }

        include_examples 'summed attributes'
      end

      describe 'with both kinds of tasks' do
        let!(:task1) { Factory(:data_collection_task, :staff_weekly_expense => sp_record) }
        let!(:task2) { Factory(:management_task, :staff_weekly_expense => sp_record) }

        include_examples 'summed attributes'
      end
    end

    describe 'for ManagementTasks' do
      let(:producer_names) { [:management_tasks] }

      let(:staff) { Factory(:valid_staff) }
      let(:expense) { Factory(:staff_weekly_expense, :staff => staff) }
      let(:sp_model) { ManagementTask }
      let!(:sp_record) { Factory(:management_task, :staff_weekly_expense => expense) }

      it 'uses the public ID for the associated weekly expense' do
        results.first.staff_weekly_expense_id.should == StaffWeeklyExpense.first.weekly_exp_id
      end

      it 'generates one WH record per SP record' do
        results.size.should == 1
      end

      include_examples 'one-to-one valid'
      include_examples 'staff associated'

      context do
        include_context 'mapping test'

        [
          [:task_type, ncs_code(11), :mgmt_task_type, '11'],
          [:task_type_other, 'Shuffling', :mgmt_task_type_oth],
          [:hours, '12.0', :mgmt_task_hrs],
          [:hours, BigDecimal.new('0.12E2'), :mgmt_task_hrs, '12.0'],
          [:hours, nil, :mgmt_task_hrs, '0.0'],
          [:comment, 'Tempus fugit', :mgmt_task_comment]
        ].each { |args| verify_mapping(*args) }
      end
    end

    describe 'for DataCollectionTask' do
      let(:producer_names) { [:data_collection_tasks] }

      let(:staff) { Factory(:valid_staff) }
      let(:expense) { Factory(:staff_weekly_expense, :staff => staff) }
      let(:sp_model) { DataCollectionTask }
      let!(:sp_record) { Factory(:data_collection_task, :staff_weekly_expense => expense) }

      include_examples 'one-to-one valid'
      include_examples 'staff associated'

      it 'uses the public ID for the associated weekly expense' do
        results.first.staff_weekly_expense_id.should == StaffWeeklyExpense.first.weekly_exp_id
      end

      it 'generates one WH record per SP record' do
        results.size.should == 1
      end

      context do
        include_context 'mapping test'

        [
          [:task_type, ncs_code(7), :data_coll_task_type, '7'],
          [:task_type_other, 'Sketching', :data_coll_task_type_oth],
          [:cases, 18, :data_coll_task_cases, '18'],
          [:transmit, 4, :data_coll_transmit, '4'],
          [:hours, '12.0', :data_coll_tasks_hrs],
          [:hours, nil, :data_coll_tasks_hrs, '0.0'],
          [:comment, 'DC', :data_coll_task_comment]
        ].each { |args| verify_mapping(*args) }
      end
    end

    describe 'for OutreachEvent' do
      let(:producer_names) { [:outreach_events] }
      let(:sp_model) { OutreachEvent }

      let!(:ncs_area) { Factory(:ncs_area) }
      let!(:ncs_area_ssu) { Factory(:ncs_area_ssu, :ncs_area => ncs_area, :ssu_id => '1234567890') }
      let!(:outreach_segment) { Factory(:outreach_segment, :ncs_area => ncs_area) }
      let!(:outreach_event) {
        Factory(:outreach_event, :outreach_segments => [outreach_segment])
      }

      shared_examples 'a basic outreach event' do
        include_context 'mapping test'

        let(:sp_record) { outreach_event }

        it 'has a derived public ID' do
          results.first.outreach_event_id.should ==
            "staff_portal-#{outreach_event.id}-#{ncs_area_ssu.ssu_id}"
        end

        include_examples 'one-to-one valid'

        [
          [:event_date, Date.new(2011, 7, 5), :outreach_event_date, '2011-07-05'],
          [:mode, ncs_code(8), :outreach_mode, '8'],
          [:mode_other, 'E', :outreach_mode_oth],
          [:outreach_type, ncs_code(5), :outreach_type, '5'],
          [:culture_other, 'Secular Humanist', :outreach_culture_oth],
          [:cost, '250.00', :outreach_cost, '250.0'],
          [:cost, nil, :outreach_cost, '0.0'],
          [:no_of_staff, 18, :outreach_staffing, '18'],
          [:evaluation_result, ncs_code(4), :outreach_eval_result, '4']
        ].each { |args| verify_mapping(*args) }

        it 'includes the other language from a different table' do
          Factory(:outreach_language,
            :outreach_event => outreach_event, :language_other => 'Babylonian')
          results.first.outreach_lang_oth.should == 'Babylonian'
        end

        it 'sums letters and attendees for quantity' do
          outreach_event.update_attributes(:letters_quantity => 8, :attendees_quantity => 3)

          results.first.outreach_quantity.should == '11'
        end

        it 'always uses "no" for incidents (until incidents are supported)' do
          results.first.outreach_incident.should == '2'
        end

        it 'produces one record per SSU in the area' do
          Factory(:ncs_area_ssu, :ncs_area => ncs_area, :ssu_id => '42')
          Factory(:ncs_area_ssu, :ncs_area => ncs_area, :ssu_id => '7')

          results.size.should == 3
        end

        it 'produces one record per SSU per area' do
          area2 = Factory(:ncs_area)
          Factory(:ncs_area_ssu, :ncs_area => area2, :ssu_id => '5')
          Factory(:outreach_segment, :outreach_event => outreach_event, :ncs_area => area2)

          results.size.should == 2
        end

        it 'gives each separate record a unique ID' do
          Factory(:ncs_area_ssu, :ncs_area => ncs_area, :ssu_id => '42')
          Factory(:ncs_area_ssu, :ncs_area => ncs_area, :ssu_id => '7')

          results.collect(&:outreach_event_id).uniq.size.should == 3
        end
      end

      describe 'when tailored' do
        before do
          outreach_event.update_attribute(:tailored_code, 1)
        end

        it_behaves_like 'a basic outreach event'

        it 'has the correct tailored value' do
          results.first.outreach_tailored.should == '1'
        end

        [
          %w(language outreach_lang1),
          %w(race outreach_race1),
          %w(culture outreach_culture1)
        ].each do |which, wh_var|
          describe "#{which} specificity" do
            it 'is the set value if set' do
              outreach_event.update_attribute(:"#{which}_specific_code", 1)
              results.first.send(wh_var).should == '1'
            end

            it 'is the unknown value if not set' do
              outreach_event.update_attribute(:"#{which}_specific_code", nil)
              results.first.send(wh_var).should == '-4'
            end
          end
        end

        describe 'designated culture' do
          it 'is the set value if set' do
            outreach_event.update_attribute(:culture_code, 8)
            results.first.outreach_culture2.should == '8'
          end

          it 'is the missing value if missing' do
            outreach_event.update_attribute(:culture_code, nil)
            results.first.outreach_culture2.should == '-4'
          end
        end
      end

      describe 'when untailored' do
        before do
          # Why does update_attribute work everywhere else but not here?
          outreach_event.tailored = Factory(:ncs_code, :local_code => 2)
          outreach_event.save!
        end

        it_behaves_like 'a basic outreach event'

        it 'has the correct tailored value' do
          results.first.outreach_tailored.should == '2'
        end

        it 'is not for a specific language' do
          results.first.outreach_lang1.should == '2'
        end

        it 'is not for a specific race' do
          results.first.outreach_race1.should == '2'
        end

        it 'is not for a specific culture' do
          results.first.outreach_culture1.should == '2'
        end

        it 'does not designate a culture' do
          results.first.outreach_culture2.should == '-7'
        end

        describe 'specifying language and race' do
          let(:producer_names) { [:outreach_untailored_automatic] }
          let(:lang_results) { results.select { |r| r.is_a?(MdesModule::OutreachLang2) } }
          let(:race_results) { results.select { |r| r.is_a?(MdesModule::OutreachRace) } }

          it 'uses English (code=1) as the language' do
            lang_results.first.outreach_lang2.should == '1'
          end

          it 'uses NA (code=-7) as the race' do
            race_results.first.outreach_race2.should == '-7'
          end

          it 'produces a valid language record' do
            record_should_be_valid(lang_results.first)
          end

          it 'produces a valid race record' do
            record_should_be_valid(race_results.first)
          end

          describe 'with multiple SSUs' do
            before do
              Factory(:ncs_area_ssu, :ncs_area => ncs_area, :ssu_id => '42')
            end

            it 'produces multiple languages, each with a unique ID' do
              lang_results.collect(&:outreach_lang2_id).uniq.size.should == 2
            end

            it 'produces multiple races, each with a unique ID' do
              race_results.collect(&:outreach_race_id).uniq.size.should == 2
            end
          end
        end
      end

      describe 'and languages' do
        let(:producer_names) { [:outreach_languages] }
        let(:sp_model) { OutreachLanguage }

        let!(:outreach_language) {
          Factory(:outreach_language,
            :outreach_event => outreach_event, :language => Factory(:ncs_code, :local_code => 4))
        }
        let(:sp_record) { outreach_language }

        it 'has the correct derived outreach event ID' do
          results.first.outreach_event_id.should ==
            "staff_portal-#{outreach_event.id}-#{ncs_area_ssu.ssu_id}"
        end

        it 'has the correct derived record ID' do
          results.first.outreach_lang2_id.should ==
            "staff_portal-#{outreach_event.id}-#{ncs_area_ssu.ssu_id}-L#{outreach_language.id}"
        end

        include_examples 'one-to-one valid'

        describe 'with multiple languages' do
          let!(:outreach_language2) {
            Factory(:outreach_language,
              :outreach_event => outreach_event,
              :language => Factory(:ncs_code, :local_code => 6))
          }

          it 'produces one record per SSU per language' do
            Factory(:ncs_area_ssu, :ncs_area => ncs_area, :ssu_id => '42')

            results.collect(&:outreach_lang2).sort.should == %w(4 4 6 6)
          end

          it 'gives each language record a unique ID' do
            results.collect(&:outreach_lang2_id).uniq.size.should == 2
          end
        end
      end

      describe 'and races' do
        let(:producer_names) { [:outreach_races] }
        let(:sp_model) { OutreachRace }

        let!(:outreach_race) {
          Factory(:outreach_race,
            :outreach_event => outreach_event,
            :race => Factory(:ncs_code, :local_code => 4, :list_name => 'RACE_CL3'))
        }
        let(:sp_record) { outreach_race }

        it 'has the correct derived outreach event ID' do
          results.first.outreach_event_id.should ==
            "staff_portal-#{outreach_event.id}-#{ncs_area_ssu.ssu_id}"
        end

        it 'has the correct derived record ID' do
          results.first.outreach_race_id.should ==
            "staff_portal-#{outreach_event.id}-#{ncs_area_ssu.ssu_id}-R#{outreach_race.id}"
        end

        include_examples 'one-to-one valid'

        context do
          include_context 'mapping test'

          verify_mapping(:race_other, 'Klingon', :outreach_race_oth)
        end

        describe 'with multiple races' do
          let!(:outreach_race2) {
            Factory(:outreach_race,
              :outreach_event => outreach_event,
              :race => Factory(:ncs_code, :local_code => 6))
          }

          it 'produces one record per SSU per race' do
            Factory(:ncs_area_ssu, :ncs_area => ncs_area, :ssu_id => '42')

            results.collect(&:outreach_race2).sort.should == %w(4 4 6 6)
          end

          it 'gives each record a unique ID' do
            results.collect(&:outreach_race_id).uniq.size.should == 2
          end
        end
      end

      describe 'and targets' do
        let(:producer_names) { [:outreach_targets] }
        let(:sp_model) { OutreachTarget }

        let(:sp_record) { outreach_event.outreach_targets.first }

        it 'has the correct derived outreach event ID' do
          results.first.outreach_event_id.should ==
            "staff_portal-#{outreach_event.id}-#{ncs_area_ssu.ssu_id}"
        end

        it 'has the correct derived record ID' do
          results.first.outreach_target_id.should ==
            "staff_portal-#{outreach_event.id}-#{ncs_area_ssu.ssu_id}-T#{outreach_event.outreach_targets.first.id}"
        end

        include_examples 'one-to-one valid'

        context do
          include_context 'mapping test'

          verify_mapping(:target_other, 'Hay bale', :outreach_target_ms_oth)
        end

        describe 'with multiple targets' do
          let!(:outreach_target2) {
            Factory(:outreach_target,
              :outreach_event => outreach_event,
              :target => Factory(:ncs_code, :local_code => 3))
          }

          it 'produces one record per SSU per target' do
            Factory(:ncs_area_ssu, :ncs_area => ncs_area, :ssu_id => '42')

            results.collect(&:outreach_target_ms).sort.should == %w(10 10 3 3)
          end

          it 'gives each record a unique ID' do
            results.collect(&:outreach_target_id).uniq.size.should == 2
          end
        end
      end

      describe 'and evaluations' do
        let(:producer_names) { [:outreach_evaluations] }
        let(:sp_model) { OutreachEvaluation }

        let!(:outreach_evaluation) {
          outreach_event.outreach_evaluations.first
        }
        let(:sp_record) { outreach_evaluation }

        it 'has the correct derived outreach event ID' do
          results.first.outreach_event_id.should ==
            "staff_portal-#{outreach_event.id}-#{ncs_area_ssu.ssu_id}"
        end

        it 'has the correct derived record ID' do
          results.first.outreach_event_eval_id.should ==
            "staff_portal-#{outreach_event.id}-#{ncs_area_ssu.ssu_id}-E#{outreach_evaluation.id}"
        end

        include_examples 'one-to-one valid'

        context do
          include_context 'mapping test'

          verify_mapping(:evaluation_other, 'Too slow', :outreach_eval_oth)
        end

        describe 'with multiple evaluations' do
          let!(:outreach_evaluation2) {
            Factory(:outreach_evaluation,
              :outreach_event => outreach_event,
              :evaluation => Factory(:ncs_code, :local_code => 6))
          }

          it 'produces one record per SSU per eval' do
            Factory(:ncs_area_ssu, :ncs_area => ncs_area, :ssu_id => '42')

            results.collect(&:outreach_eval).sort.should == %w(1 1 6 6)
          end

          it 'gives each record a unique ID' do
            results.collect(&:outreach_event_eval_id).uniq.size.should == 2
          end
        end
      end

      describe 'and staff' do
        let(:producer_names) { [:outreach_staff_members] }
        let(:sp_model) { OutreachStaffMember }

        let!(:outreach_staff_member) {
          outreach_event.outreach_staff_members.first
        }
        let(:staff) { outreach_staff_member.staff }
        let(:sp_record) { outreach_staff_member }

        it 'has the correct derived outreach event ID' do
          results.first.outreach_event_id.should ==
            "staff_portal-#{outreach_event.id}-#{ncs_area_ssu.ssu_id}"
        end

        it 'has the correct derived record ID' do
          results.first.outreach_event_staff_id.should ==
            "staff_portal-#{outreach_event.id}-#{ncs_area_ssu.ssu_id}-S#{outreach_staff_member.id}"
        end

        it 'uses the public ID for the staff member' do
          results.first.staff_id.should == outreach_staff_member.staff.public_id
        end

        include_examples 'one-to-one valid'
        include_examples 'staff associated'

        describe 'with multiple staff' do
          let!(:outreach_staff_member2) {
            Factory(:outreach_staff_member,
              :outreach_event => outreach_event,
              :staff => Factory(:valid_staff, :first_name => 'Jane'))
          }

          it 'produces one record per SSU per staff' do
            Factory(:ncs_area_ssu, :ncs_area => ncs_area, :ssu_id => '42')

            results.size.should == 4
          end

          it 'gives each record a unique ID' do
            results.collect(&:outreach_event_staff_id).uniq.size.should == 2
          end
        end
      end
    end
  end
end
