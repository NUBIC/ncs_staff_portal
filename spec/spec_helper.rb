require 'rubygems'
require 'spork'

require 'postgresql_adapter_patches'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  ENV["RAILS_ENV"] ||= 'test'
  require 'ncs_navigator/configuration'
  NcsNavigator.configuration =
    NcsNavigator::Configuration.new(File.expand_path('../configuration/navigator.ini', __FILE__))

  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  require 'factory_girl'
  require 'rspec/rails'
  
  RSpec.configure do |config|
    config.treat_symbols_as_metadata_keys_with_true_values = true

    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec

    config.before(:all) do
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)
      NcsNavigator::StaffPortal::MdesCodeListLoader.new.load_from_yaml
    end

    config.before(:each, :clean_with_truncation) do
      DatabaseCleaner.strategy = :truncation
    end

    config.after(:each, :clean_with_truncation) do
      DatabaseCleaner.strategy = :transaction
    end

    config.before(:each) do
      DatabaseCleaner.start
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end

    config.include Aker::Rails::Test::Helpers
  end

  # Preload slow warehouse infrastructure only when actually using spork
  if Spork.using_spork?
    puts 'Preloading warehouse models (spork only)'
    require 'ncs_navigator/warehouse'
    require 'ncs_navigator/warehouse/models/three_point_zero'
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.

  FactoryGirl.reload
end
