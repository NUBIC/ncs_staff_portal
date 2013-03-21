require 'spec_helper'

module NcsNavigator::StaffPortal::Mdes::VersionMigrations
  describe Basic do
    let(:migrator) { Basic.new(StaffPortal.mdes_version.number, '2.2') }

    describe '#initialize' do
      it 'sets #from' do
        migrator.from.should == StaffPortal.mdes_version.number
      end

      it 'sets #to' do
        migrator.to.should == '2.2'
      end
    end

    describe '#run' do
      before do
        MdesVersion.set!(migrator.from)
        migrator.run
      end

      after do
        # restore the code list to the current version
        NcsNavigator::StaffPortal::MdesCodeListLoader.new.load_from_yaml
      end

      it 'updates the MDES version in the database' do
        MdesVersion.new.number.should == migrator.to
      end

      let(:target_version_code_lists) {
        NcsNavigator::Mdes(migrator.to).types.
          select { |vt| vt.code_list }.collect { |vt| vt.name.upcase }.sort
      }

      def select_one_column(query)
        ActiveRecord::Base.connection.select_all(query).
          collect { |row| row.values.first }
      end

      it "changes the code lists to the targeted version's lists" do
        select_one_column("SELECT DISTINCT list_name FROM ncs_codes ORDER BY list_name").
          should == target_version_code_lists
      end
    end
  end
end