require 'spec_helper'

module NcsNavigator::StaffPortal::Warehouse
  describe NotImportedPassthrough, :warehouse do
    let(:wh_config)   { NcsNavigator::Warehouse::Configuration.new }
    let(:passthrough) { NotImportedPassthrough.new(wh_config) }

    describe '#create_emitter', :slow do
      subject { passthrough.create_emitter }

      let(:model_tables) { subject.models.collect(&:mdes_table_name) }

      it 'includes PII' do
        subject.include_pii?.should be_true
      end

      it 'skips the ZIP' do
        subject.zip?.should be_false
      end

      it 'writes to a file in the importer_passthrough directory' do
        subject.filename.to_s.should =~
          %r(#{Rails.root}/importer_passthrough/outside_staff-\d{14}.xml)
      end

      it 'does not include core operational models' do
        model_tables.should_not include('person')
      end

      it 'does not include instrument models' do
        model_tables.should_not include('pre_preg')
      end

      it 'does include staff models' do
        model_tables.should include('staff')
      end

      it 'does include outreach models' do
        model_tables.should include('outreach')
      end

      it 'contains each table only once' do
        model_tables.sort.should == model_tables.uniq.sort
      end
    end

    describe '#import' do
      let(:mock_emitter) { mock(NcsNavigator::Warehouse::XmlEmitter) }

      it 'emits the XML' do
        passthrough.should_receive(:create_emitter).and_return(mock_emitter)
        mock_emitter.should_receive(:emit_xml)

        passthrough.import
      end
    end
  end
end
