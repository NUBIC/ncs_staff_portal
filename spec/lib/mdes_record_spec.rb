require 'spec_helper'

require 'mdes_record'

describe MdesRecord do
  it 'automatically mixed into AR::Base' do
    ActiveRecord::Base.should respond_to(:acts_as_mdes_record)
  end
end

describe MdesRecord::ActsAsMdesRecord do
  describe 'public IDs' do
    let(:test_class) {
      Class.new(Struct.new(:info_id)) do
        class << self
          def after_initialize(*args)
            after_initializes.concat(args)
          end

          def after_initializes
            @after_initializes ||= []
          end
        end

        extend MdesRecord
        acts_as_mdes_record :public_id => :info_id
      end
    }

    describe 'extending the class' do
      it 'adds a public_id_attribute_name' do
        test_class.public_id_attribute_name.should == :info_id
      end

      it 'registers an after_initialize callback' do
        test_class.after_initializes.should == [:public_id]
      end
    end

    describe 'extending an instance' do
      subject { test_class.new '12' }

      it 'adds a public_id reader' do
        subject.public_id.should == '12'
      end

      it 'adds a public_id writer' do
        subject.public_id = '42'
        subject.info_id.should == '42'
      end

      it 'automatically sets the public ID on first access' do
        subject.info_id = nil

        subject.public_id.should_not be_nil
        subject.info_id.should == subject.public_id
      end

      describe 'ID generation' do
        it 'generates a different ID each time' do
          a = test_class.new(nil)
          b = test_class.new(nil)
          a.public_id.should_not == b.public_id
        end
      end
    end
  end
end
