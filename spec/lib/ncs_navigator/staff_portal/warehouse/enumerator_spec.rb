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
  end
end
