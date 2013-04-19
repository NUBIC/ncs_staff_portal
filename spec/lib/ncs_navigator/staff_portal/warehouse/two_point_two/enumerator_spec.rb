require 'spec_helper'

module NcsNavigator::StaffPortal::Warehouse::TwoPointTwo
  describe 'Enumerator', :clean_with_truncation, :slow, :warehouse do
    let!(:wh_config) {
      NcsNavigator::Warehouse::Configuration.new.tap do |config|
      	config.mdes_version = '2.2'
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
    let(:staff) { Factory(:valid_staff) }
    let(:other_staff) {
      Factory(:valid_staff, :first_name => 'Jane', :username => 'jh675', :email => 'jh@example.edu')
    }

    it 'can be created' do
      Enumerator.create_transformer(wh_config).should respond_to(:transform)
    end

    it 'uses the correct bcdatabase config' do
      Enumerator.bcdatabase[:name].should == 'ncs_staff_portal'
    end

    shared_context 'mapping test 2.2' do
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

    shared_examples 'one-to-one valid 2.2' do
      it 'produces a single valid warehouse record from a valid NCS Navigator Ops record' do
        sp_record.should be_valid
        record_should_be_valid(results.first)
      end
    end

    shared_examples 'staff associated 2.2' do
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
        Factory(:staff, :zipcode => nil)

        results.collect(&:staff_zip).should == %w(92131)
      end

      include_examples 'one-to-one valid 2.2'

      context do
        include_context 'mapping test 2.2'

        [
          # prefix breaks default behavior
          [:staff_id, 'Eleventy', :staff_id],
          [:comment, 'Short', :staff_comment],
          [:zipcode, '00101', :staff_zip],
          [:experience, ncs_code(1), :staff_exp, '1']
        ].each { |args| verify_mapping(*args) }

        describe 'year of birth' do
          it 'is extracted from yob when staff_yob set' do
            sp_record.update_attribute(:yob_staff, 1985)
            results.last.staff_yob.should == '1985'
          end

          it 'is extracted from dob when staff_yob is null' do
            results.last.staff_yob.should == '1977'
          end

          it 'is blank when dob unknown' do
            sp_record.update_attribute(:birth_date, nil)
            results.last.staff_yob.should be_nil
          end
        end

        describe 'age range' do
          it "is set same as of age group code if age group code is set" do
            expected_code = 3
            sp_record.update_attribute(:age_group_code, expected_code)
            results.last.staff_age_range.should == expected_code.to_s
          end

          describe "computed from date of birth" do
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

        describe 'ncs_active_date' do
          it 'is blank when not set' do
            results.last.ncs_active_date.should be_nil
          end

          it 'is extracted when set' do
            sp_record.update_attribute(:ncs_active_date, '2012-05-12')
            results.last.ncs_active_date.should == '2012-05-12'
          end
        end

        describe 'ncs_inactive_date' do
          it 'is blank when not set' do
            results.last.ncs_inactive_date.should be_nil
          end

          it 'is extracted when set' do
            sp_record.update_attribute(:ncs_inactive_date, '2012-05-30')
            results.last.ncs_inactive_date.should == '2012-05-30'
          end
        end
      end
    end

    describe 'for StaffLanguage' do
      let(:sp_model) { StaffLanguage }
      let(:other_code) { Factory(:ncs_code, :list_name => 'LANGUAGE_CL2', :local_code => '-5') }

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

        include_examples 'staff associated 2.2'
        include_examples 'one-to-one valid 2.2'
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

        include_examples 'staff associated 2.2'

        it 'ignores coded entries' do
          Factory(:staff_language, :staff => staff)

          results.size.should == 1
        end

        it 'aggregates multiple "other" languages into one WH other entry' do
          # Intentionally an array with one string
          results.collect(&:staff_lang_oth).should == ['Esperanto,Aramaic']
        end

        it 'uses the staff_language_id of the record whose id is max among all the ids of the other languages for staff' do
          Factory(:staff_language, :lang => other_code, :lang_other => 'Aramaic', :staff => staff,
            :staff_language_id => 'B')
          results.collect(&:staff_language_id).should == ['B']
        end

        it 'includes the other code' do
          results.collect(&:staff_lang).should == ['-5']
        end

        it 'aggregates within a single staff member only' do
          Factory(:staff_language, :lang => other_code, :lang_other => 'Gujarati',
            :staff => other_staff)
          results.collect(&:staff_lang_oth).sort.should == ['Esperanto,Aramaic', 'Gujarati']
        end
      end
    end

    describe 'for StaffCertTraining' do
      let!(:sp_record) { Factory(:staff_cert_training, :staff => staff) }
      let(:sp_model) { StaffCertTraining }

      let(:producer_names) { [:staff_cert_trainings] }

      it 'uses the public ID for staff' do
        results.first.staff_id.should == Staff.first.staff_id
      end

      it 'generates one WH record per SP record' do
        results.size.should == 1
      end

      include_examples 'one-to-one valid 2.2'
      include_examples 'staff associated 2.2'

      context do
        include_context 'mapping test 2.2'

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
      let!(:sp_record) { Factory(:staff_weekly_expense, :staff => staff) }
      let(:sp_model) { StaffWeeklyExpense }

      let(:producer_names) { [:staff_weekly_expenses] }

      it 'uses the public ID for staff' do
        results.first.staff_id.should == Staff.first.staff_id
      end

      it 'uses its own public ID' do
        results.first.weekly_exp_id.should == sp_record.weekly_exp_id
      end

      include_examples 'one-to-one valid 2.2'
      include_examples 'staff associated 2.2'

      context do
        include_examples 'mapping test 2.2'

        [
          [:week_start_date, Date.new(2011, 4, 8), :week_start_date, '2011-04-08'],
          [:comment, 'Slow week', :weekly_expenses_comment],
          [:rate, '23.4', :staff_pay]
        ].each { |args| verify_mapping(*args) }
      end

      shared_examples 'summed attributes 2.2' do
        include_context 'mapping test 2.2'

        it 'produces one expense record for many tasks' do
          results.size.should == 1
        end

        it 'produces separate WH records for separate SP records' do
          task2.update_attribute(:staff_weekly_expense,
            Factory(:staff_weekly_expense, :staff => other_staff))
          results.size.should == 2
        end

        describe 'hours' do
          it 'uses weekly_expense hours if set' do
            sp_record.update_attribute(:hours, '51.25')
            results.first.staff_hours.should == '51.25'
          end

          it 'sums across all tasks if weekly_expense hours are null' do
            sp_record.hours.should be_nil
            task1.update_attributes(:hours => '16.02')
            task2.update_attributes(:hours => '90.00')
            task3.update_attributes(:hours => '10.00')

            results.first.staff_hours.should == '116.02'
          end

          it 'uses 0.0 if there are no hours' do
            results.first.staff_hours.should == '0.0'
          end
        end

        describe 'expenses' do
          it 'uses weekly_expense expenses if set' do
            sp_record.update_attribute(:expenses, '153.45')
            results.first.staff_expenses.should == '153.45'
          end

          it 'sums across all tasks if weekly_expense expenses are null' do
            sp_record.expenses.should be_nil
            task1.update_attributes(:expenses =>  '9.99')
            task2.update_attributes(:expenses => '10.08')
            task3.update_attributes(:expenses => '11.08')

            results.first.staff_expenses.should == '31.15'
          end

          it 'uses 0.0 if there are no expenses' do
            results.first.staff_expenses.should == '0.0'
          end
        end

        describe 'miles' do
          it 'uses weekly_expense miles if set' do
            sp_record.update_attribute(:miles, '20.57')
            results.first.staff_miles.should == '20.57'
          end

          it 'sums across all tasks if weekly_expense miles are null' do
            sp_record.miles.should be_nil
            task1.update_attributes(:miles =>  '52.02')
            task2.update_attributes(:miles => '150.21')
            task3.update_attributes(:miles => '50.21')

            results.first.staff_miles.should == '252.44'
          end

          it 'uses 0.0 if there are no miles' do
            results.first.staff_miles.should == '0.0'
          end
        end
      end

      describe 'with management tasks' do
        let!(:task1) { Factory(:management_task, :staff_weekly_expense => sp_record) }
        let!(:task2) { Factory(:management_task, :staff_weekly_expense => sp_record) }
        let!(:task3) { Factory(:management_task, :staff_weekly_expense => sp_record) }

        include_examples 'summed attributes 2.2'
      end

      describe 'with data collection tasks' do
        let!(:task1) { Factory(:data_collection_task, :staff_weekly_expense => sp_record) }
        let!(:task2) { Factory(:data_collection_task, :staff_weekly_expense => sp_record) }
        let!(:task3) { Factory(:data_collection_task, :staff_weekly_expense => sp_record) }

        include_examples 'summed attributes 2.2'
      end

      describe 'with both kinds of tasks and miscellaneous_expense' do
        let!(:task1) { Factory(:data_collection_task, :staff_weekly_expense => sp_record) }
        let!(:task2) { Factory(:management_task, :staff_weekly_expense => sp_record) }
        let!(:task3) { Factory(:miscellaneous_expense, :staff_weekly_expense => sp_record) }

        include_examples 'summed attributes 2.2'
      end
    end

    describe 'for ManagementTasks' do
      let(:producer_names) { [:management_tasks] }

      let(:expense) { Factory(:staff_weekly_expense, :staff => staff) }
      let(:sp_model) { ManagementTask }
      let!(:sp_record) { Factory(:management_task, :staff_weekly_expense => expense) }

      it 'uses the public ID for the associated weekly expense' do
        results.first.staff_weekly_expense_id.should == StaffWeeklyExpense.first.weekly_exp_id
      end

      it 'generates one WH record per SP record' do
        results.size.should == 1
      end

      include_examples 'one-to-one valid 2.2'
      include_examples 'staff associated 2.2'

      context do
        include_context 'mapping test 2.2'

        [
          [:task_type, ncs_code(11), :mgmt_task_type, '11'],
          [:task_type_other, nil, :mgmt_task_type_oth],
          [:hours, '12.0', :mgmt_task_hrs],
          [:hours, BigDecimal.new('0.12E2'), :mgmt_task_hrs, '12.0'],
          [:hours, nil, :mgmt_task_hrs, '0.0'],
          [:comment, 'Tempus fugit', :mgmt_task_comment]
        ].each { |args| verify_mapping(*args) }
      end
    end

    describe 'for DataCollectionTask' do
      let(:producer_names) { [:data_collection_tasks] }

      let(:expense) { Factory(:staff_weekly_expense, :staff => staff) }
      let(:sp_model) { DataCollectionTask }
      let!(:sp_record) { Factory(:data_collection_task, :staff_weekly_expense => expense) }

      include_examples 'one-to-one valid 2.2'
      include_examples 'staff associated 2.2'

      it 'uses the public ID for the associated weekly expense' do
        results.first.staff_weekly_expense_id.should == StaffWeeklyExpense.first.weekly_exp_id
      end

      it 'generates one WH record per SP record' do
        results.size.should == 1
      end

      context do
        include_context 'mapping test 2.2'

        [
          [:task_type, ncs_code(7), :data_coll_task_type, '7'],
          [:task_type_other, nil, :data_coll_task_type_oth],
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

      let!(:ncs_ssu) { Factory(:ncs_ssu, :ssu_id => '1234567890') }
      let!(:outreach_segment) { Factory(:outreach_segment, :ncs_ssu => ncs_ssu) }
      let!(:outreach_event) {
        Factory(:outreach_event, :outreach_segments => [outreach_segment])
      }

      shared_examples 'a basic outreach event 2.2' do
        include_context 'mapping test 2.2'

        let(:sp_record) { outreach_event }

        describe "public_id" do
          it 'uses the source_id as public_id if source_id is not nil' do
            outreach_event.update_attribute(:source_id, "source_id_123")
            results.first.outreach_event_id.should == "source_id_123"
          end

          it 'has a derived public ID' do
            results.first.outreach_event_id.should ==
              "staff_portal-#{outreach_event.id}-#{ncs_ssu.ssu_id}"
          end
        end

        include_examples 'one-to-one valid 2.2'

        [
          [:event_date, '2011-07-05', :outreach_event_date, '2011-07-05'],
          [:mode, ncs_code(8), :outreach_mode, '8'],
          [:mode_other, nil, :outreach_mode_oth],
          [:outreach_type, ncs_code(5), :outreach_type, '5'],
          [:culture_other, nil, :outreach_culture_oth],
          [:cost, '250.00', :outreach_cost, '250.0'],
          [:cost, nil, :outreach_cost, '0.0'],
          [:no_of_staff, 18, :outreach_staffing, '18'],
          [:evaluation_result, ncs_code(4), :outreach_eval_result, '4']
        ].each { |args| verify_mapping(*args) }

        it 'includes the other language from a different table' do
          Factory(:outreach_language,
            :outreach_event => outreach_event, :language_other => 'Babylonian', :language => Factory(:ncs_code, :local_code => -5))
          results.first.outreach_lang_oth.should == 'Babylonian'
        end

        it 'uses 0 for quantity when letters and attendees are null' do
          results.first.outreach_quantity.should == '0'
        end

        it 'sums letters and attendees for quantity when letters and attendees are not null' do
          outreach_event.update_attributes(:letters_quantity => 8, :attendees_quantity => 3)

          results.first.outreach_quantity.should == '11'
        end

        it 'uses attendees for quantity if letters null' do
          outreach_event.update_attributes(:attendees_quantity => 15)

          results.first.outreach_quantity.should == '15'
        end

        it 'uses letters for quantity if attendees null' do
          outreach_event.update_attributes(:letters_quantity => 8)

          results.first.outreach_quantity.should == '8'
        end

        it 'always uses "no" for incidents (until incidents are supported)' do
          results.first.outreach_incident.should == '2'
        end

        it 'gives each separate record a unique ID' do
          Factory(:outreach_segment, :ncs_ssu => Factory(:ncs_ssu, :ssu_id => '42'), :outreach_event => outreach_event)
          Factory(:outreach_segment, :ncs_ssu => Factory(:ncs_ssu, :ssu_id => '7'), :outreach_event => outreach_event)
          results.collect(&:outreach_event_id).uniq.size.should == 3
        end

        it 'includes tsu_id if event has any tsu associated' do
           outreach_segment.update_attribute(:ncs_tsu, Factory(:ncs_tsu, :tsu_id => 'tsu_id1'))
           results.first.tsu_id.should == 'tsu_id1'
        end

        describe "when no ssu" do
          before do
            outreach_event.update_attribute(:outreach_segments, [])
          end

          it 'has a derived public ID without ssu_id associated' do
            results.first.outreach_event_id.should ==
              "staff_portal-#{outreach_event.id}"
          end

          it 'includes ssu_id as nil' do
            results.first.ssu_id.should be_nil
          end
        end
      end

      describe 'when tailored' do
        before do
          outreach_event.update_attribute(:tailored_code, 1)
        end

        it_behaves_like 'a basic outreach event 2.2'

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
        describe 'when source_id is set' do
          before do
          # Why does update_attribute work everywhere else but not here?
            outreach_event.tailored = Factory(:ncs_code, :local_code => 2)
            outreach_event.update_attribute(:source_id, "source_id_123")
            outreach_event.save!
          end

          it 'has the correct outreach_event_id as source_id' do
            results.first.outreach_event_id.should == 'source_id_123'
          end

          it 'has the correct tailored value' do
            results.first.outreach_tailored.should == '2'
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

          describe 'designate a culture' do
            it 'is the set value if set' do
              outreach_event.update_attribute(:culture_code, 1)
              results.first.outreach_culture2.should == '1'
            end

            it 'is the unknown value if not set' do
              outreach_event.update_attribute(:culture_code, nil)
              results.first.outreach_culture2.should == '-4'
            end
          end

          describe 'specifying language and race' do
            let(:producer_names) { [:outreach_untailored_automatic] }
            let(:lang_results) { results.select { |r| r.is_a?(wh_config.model(:OutreachLang2)) } }
            let(:race_results) { results.select { |r| r.is_a?(wh_config.model(:OutreachRace)) } }

            it 'does not generate the OutreachLang2' do
              lang_results.should be_empty
            end

            it 'does not generate the OutreachRace' do
              race_results.should be_empty
            end
          end
        end

        describe 'when source_id is not set' do
          before do
            # Why does update_attribute work everywhere else but not here?
            outreach_event.tailored = Factory(:ncs_code, :local_code => 2)
            outreach_event.save!
          end

          it_behaves_like 'a basic outreach event 2.2'

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
            let(:lang_results) { results.select { |r| r.is_a?(wh_config.model(:OutreachLang2)) } }
            let(:race_results) { results.select { |r| r.is_a?(wh_config.model(:OutreachRace)) } }

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
                Factory(:outreach_segment, :ncs_ssu => Factory(:ncs_ssu, :ssu_id => '42'), :outreach_event => outreach_event)
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
      end

      describe 'and languages' do
        let(:producer_names) { [:outreach_languages] }
        let(:sp_model) { OutreachLanguage }

        let!(:outreach_language) {
          Factory(:outreach_language,
            :outreach_event => outreach_event, :language => Factory(:ncs_code, :local_code => 4))
        }
        let(:sp_record) { outreach_language }

        describe 'outreach event ID' do
          it 'uses source_id of outreach_event if outreach_event source_id is set' do
            outreach_event.update_attribute(:source_id, "source_id_event_123")
            results.first.outreach_event_id.should == "source_id_event_123"
          end

          it 'has the correct derived outreach event ID if outreach_event source_id is not set' do
            results.first.outreach_event_id.should ==
              "staff_portal-#{outreach_event.id}-#{ncs_ssu.ssu_id}"
          end
        end

        describe 'derived record ID' do
          it 'uses source_id if outreach_languages source_id is set' do
            outreach_language.update_attribute(:source_id, "source_id_language_123")
            results.first.outreach_lang2_id.should == "source_id_language_123"
          end

          it 'has the correct derived record ID if outreach_languages source_id is not set' do
            results.first.outreach_lang2_id.should ==
              "staff_portal-#{outreach_event.id}-#{ncs_ssu.ssu_id}-L#{outreach_language.id}"
          end

          it 'has the correct derived record ID without ssu_id if outreach event has no ssu' do
            outreach_event.update_attribute(:outreach_segments, [])
            results.first.outreach_lang2_id.should ==
              "staff_portal-#{outreach_event.id}-L#{outreach_language.id}"
          end
        end

        include_examples 'one-to-one valid 2.2'

        describe 'with multiple languages' do
          let!(:outreach_language2) {
            Factory(:outreach_language,
              :outreach_event => outreach_event,
              :language => Factory(:ncs_code, :local_code => 6))
          }

          it 'produces one record per SSU per language' do
            Factory(:outreach_segment, :ncs_ssu => Factory(:ncs_ssu, :ssu_id => '42'), :outreach_event => outreach_event)
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

        describe 'outreach event ID' do
          it 'uses source_id of outreach_event if outreach_event source_id is set' do
            outreach_event.update_attribute(:source_id, "source_id_event_123")
            results.first.outreach_event_id.should == "source_id_event_123"
          end

          it 'has the correct derived outreach event ID if outreach_event source_id is not set' do
            results.first.outreach_event_id.should ==
              "staff_portal-#{outreach_event.id}-#{ncs_ssu.ssu_id}"
          end
        end

        describe 'derived record ID' do
          it 'uses source_id if outreach_languages source_id is set' do
            outreach_race.update_attribute(:source_id, "source_id_race_123")
            results.first.outreach_race_id.should == "source_id_race_123"
          end

          it 'has the correct derived record ID if outreach_races source_id is not set' do
            results.first.outreach_race_id.should ==
              "staff_portal-#{outreach_event.id}-#{ncs_ssu.ssu_id}-R#{outreach_race.id}"
          end
        end

        include_examples 'one-to-one valid 2.2'

        context do
          include_context 'mapping test 2.2'

          verify_mapping(:race_other, nil, :outreach_race_oth)
        end

        describe 'with multiple races' do
          let!(:outreach_race2) {
            Factory(:outreach_race,
              :outreach_event => outreach_event,
              :race => Factory(:ncs_code, :local_code => 6))
          }

          it 'produces one record per SSU per race' do
            Factory(:outreach_segment, :ncs_ssu => Factory(:ncs_ssu, :ssu_id => '42'), :outreach_event => outreach_event)
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

        describe 'outreach event ID' do
          it 'uses source_id of outreach_event if outreach_event source_id is set' do
            outreach_event.update_attribute(:source_id, "source_id_event_123")
            results.first.outreach_event_id.should == "source_id_event_123"
          end

          it 'has the correct derived outreach event ID if outreach_event source_id is not set' do
            results.first.outreach_event_id.should ==
              "staff_portal-#{outreach_event.id}-#{ncs_ssu.ssu_id}"
          end
        end

        describe 'derived record ID' do
          it 'uses source_id if outreach_targets source_id is set' do
            sp_record.update_attribute(:source_id, "source_id_target_123")
            results.first.outreach_target_id.should == "source_id_target_123"
          end

          it 'has the correct derived record ID if outreach_targets source_id is not set' do
            results.first.outreach_target_id.should ==
              "staff_portal-#{outreach_event.id}-#{ncs_ssu.ssu_id}-T#{outreach_event.outreach_targets.first.id}"
          end
        end

        include_examples 'one-to-one valid 2.2'

        context do
          include_context 'mapping test 2.2'

          verify_mapping(:target_other, nil, :outreach_target_ms_oth)
        end

        describe 'with multiple targets' do
          let!(:outreach_target2) {
            Factory(:outreach_target,
              :outreach_event => outreach_event,
              :target => Factory(:ncs_code, :local_code => 3))
          }

          it 'produces one record per SSU per target' do
            Factory(:outreach_segment, :ncs_ssu => Factory(:ncs_ssu, :ssu_id => '42'), :outreach_event => outreach_event)

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

        describe 'outreach event ID' do
          it 'uses source_id of outreach_event if outreach_event source_id is set' do
            outreach_event.update_attribute(:source_id, "source_id_event_123")
            results.first.outreach_event_id.should == "source_id_event_123"
          end

          it 'has the correct derived outreach event ID if outreach_event source_id is not set' do
            results.first.outreach_event_id.should ==
              "staff_portal-#{outreach_event.id}-#{ncs_ssu.ssu_id}"
          end
        end

        describe 'derived record ID' do
          it 'uses source_id if outreach_evaluations source_id is set' do
            outreach_evaluation.update_attribute(:source_id, "source_id_evaluation_123")
            results.first.outreach_event_eval_id.should == "source_id_evaluation_123"
          end

          it 'has the correct derived record ID if outreach_evaluations source_id is not set' do
            results.first.outreach_event_eval_id.should ==
              "staff_portal-#{outreach_event.id}-#{ncs_ssu.ssu_id}-E#{outreach_evaluation.id}"
          end
        end

        include_examples 'one-to-one valid 2.2'

        context do
          include_context 'mapping test 2.2'

          verify_mapping(:evaluation_other, nil, :outreach_eval_oth)
        end

        describe 'with multiple evaluations' do
          let!(:outreach_evaluation2) {
            Factory(:outreach_evaluation,
              :outreach_event => outreach_event,
              :evaluation => Factory(:ncs_code, :local_code => 6))
          }

          it 'produces one record per SSU per eval' do
            Factory(:outreach_segment, :ncs_ssu => Factory(:ncs_ssu, :ssu_id => '42'), :outreach_event => outreach_event)

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
        let(:sp_record) { outreach_staff_member }

        before do
          outreach_staff_member.update_attribute(:staff, staff)
        end

        describe 'outreach event ID' do
          it 'uses source_id of outreach_event if outreach_event source_id is set' do
            outreach_event.update_attribute(:source_id, "source_id_event_123")
            results.first.outreach_event_id.should == "source_id_event_123"
          end

          it 'has the correct derived outreach event ID if outreach_event source_id is not set' do
            results.first.outreach_event_id.should ==
              "staff_portal-#{outreach_event.id}-#{ncs_ssu.ssu_id}"
          end
        end

        describe 'derived record ID' do
          it 'uses source_id if outreach_staff_members source_id is set' do
            outreach_staff_member.update_attribute(:source_id, "source_id_outreach_staff_123")
            results.first.outreach_event_staff_id.should == "source_id_outreach_staff_123"
          end

          it 'has the correct derived record ID if outreach_staff_members source_id is not set' do
            results.first.outreach_event_staff_id.should ==
              "staff_portal-#{outreach_event.id}-#{ncs_ssu.ssu_id}-S#{outreach_staff_member.id}"
          end
        end

        it 'uses the public ID for the staff member' do
          results.first.staff_id.should == outreach_staff_member.staff.public_id
        end

        include_examples 'one-to-one valid 2.2'
        include_examples 'staff associated 2.2'

        describe 'with multiple staff' do
          let!(:outreach_staff_member2) {
            Factory(:outreach_staff_member,
              :outreach_event => outreach_event,
              :staff => other_staff)
          }

          it 'produces one record per SSU per staff' do
            Factory(:outreach_segment, :ncs_ssu => Factory(:ncs_ssu, :ssu_id => '42'), :outreach_event => outreach_event)
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
