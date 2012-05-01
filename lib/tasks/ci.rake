begin
  require 'ci/reporter/rake/rspec'
  require 'cucumber/rake/task'

  namespace :ci do
    ENV["CI_REPORTS"] = "reports/spec-xml"

    desc "Run the full CI process"
    task :all => [:setup, :spec, :cucumber]

    desc "Run the CI specs only"
    task :specs => [:setup, :spec]

    # Prepare to run tests for CI
    task :setup => ['log:clear', :configuration_setup, 'db:migrate']

    desc "Run specs for CI (without database setup steps)"
    RSpec::Core::RakeTask.new(:spec => 'ci:setup:rspec') do |t|
      t.pattern = "spec/**/*_spec.rb"
    end

    Cucumber::Rake::Task.new(:cucumber, 'Run features for CI (without database setup steps)') do |t|
      t.fork = true
      t.profile = 'ci'
    end

    task :configuration_setup do
      require 'ncs_navigator/configuration'
      NcsNavigator.configuration =
        NcsNavigator::Configuration.new(File.expand_path('../../../spec/configuration/navigator.ini', __FILE__))
    end
  end
rescue Exception => e
  unless %w(staging production).include?(ENV['RAILS_ENV'])
    $stderr.puts "Error setting up CI tasks: #{e}"
  end
end
