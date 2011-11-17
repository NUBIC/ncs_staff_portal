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

    describe 'for Staff' do
      let(:producer_names) { [:staff] }
      let(:sp_model) { Staff }
      let!(:sp_record) { Factory(:valid_staff) }

      it 'excludes records which have been initialized but not updated' do
        pending 'Is this still necessary?'
        Factory(:staff, :validate_create => 'true', :staff_type => nil)

        results.collect(&:staff_zip).should == %w(92131)
      end

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

      it 'uses the public ID for staff' do
        results.first.staff_id.should == Staff.first.staff_id
      end

      it 'generates one WH record per SP record' do
        results.size.should == 1
      end

      context do
        include_context 'mapping test'

        [
          [:certificate_type, ncs_code(7), :cert_train_type, '7'],
          [:complete, ncs_code(2), :cert_completed, '2'],
          [:background_check, ncs_code(6), :staff_bgcheck_lvl, '6'],
          [:frequency, 4, :cert_type_frequency, '4'],
          [:expiration_date, Date.new(2014, 3, 2), :cert_type_exp_date, '2014-03-02'],
          [:comment, 'Not important', :cert_comment],
        ].each { |args| verify_mapping(*args) }
      end
    end
  end
end
