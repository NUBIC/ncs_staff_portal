require 'ci/reporter/rake/rspec'
require 'cucumber/rake/task'

namespace :ci do
  ENV["CI_REPORTS"] = "reports/spec-xml"

  desc "Run the full CI process"
  task :all => [:setup, :spec, :cucumber]
  
  desc "Run the CI specs only"
  task :specs => [:setup, :spec]

  # Prepare to run tests for CI
  task :setup => ['log:clear', 'db:migrate']

  desc "Run specs for CI (without database setup steps)"
  RSpec::Core::RakeTask.new(:spec => 'ci:setup:rspec') do |t|
    t.pattern = "spec/**/*_spec.rb"
  end

  Cucumber::Rake::Task.new(:cucumber, 'Run features for CI (without database setup steps)') do |t|
    t.fork = true
    t.profile = 'ci'
  end
end