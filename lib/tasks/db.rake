namespace 'db:remote' do
  desc "Dump this environment's database to standard out using pg_dump -Fc. Must be invoked with rake -s."
  task :out => [:environment, :tmp_pgpass] do
    params = ActiveRecord::Base.configurations[Rails.env]

    dump_command = ['pg_dump', '-Fc']
    dump_command << '-h' << params['host'] if params['host']
    dump_command << '-p' << params['port'] if params['port']
    dump_command << '-U' << params['username']
    dump_command << params['database']

    system(dump_command.join(' '))
  end

  desc "Syncs the database for the production instance on the target SERVER to this env."
  task :sync => [:environment, :tmp_pgpass] do
    server = ENV['SERVER'] or fail "Please specify the SERVER where SP production is deployed."
    remote_env = ENV['REMOTE_ENV'] || 'production'

    fail 'Do not sync into production!' if Rails.env == 'production'

    dump_command = [
      # this path is hard-coded in deploy.rb also
      'cd /var/www/apps/ncs_staff_portal/current > /dev/null',
      'if [ ! -z `which rvm 2> /dev/null` ]; then rvm use system > /dev/null; fi',
      "bundle exec rake -s db:remote:out RAILS_ENV=#{remote_env}"
    ].join(' && ')

    params = ActiveRecord::Base.configurations[Rails.env]

    restore_command = ['pg_restore', '--clean', '--no-owner', '--schema=public']
    restore_command << '-h' << params['host'] if params['host']
    restore_command << '-p' << params['port'] if params['port']
    restore_command << '-U' << params['username']
    restore_command << '-d' << params['database']

    sh("ssh #{server} '#{dump_command}' | #{restore_command.join(' ')}")

    task('db:migrate').invoke
  end

  # Sets up a temporary pgpass file for the current env
  task :tmp_pgpass => :environment do |t|
    params = ActiveRecord::Base.configurations[Rails.env]

    require 'tempfile'
    class << t; attr_accessor :tempfile; end

    t.tempfile = Tempfile.new('sp-pgpass')
    t.tempfile.puts [
      params['host'] || 'localhost',
      params['port'] || '*',
      '*',
      params['username'],
      params['password']
    ].join(':')
    t.tempfile.close

    ENV['PGPASSFILE'] = t.tempfile.path
  end
end
