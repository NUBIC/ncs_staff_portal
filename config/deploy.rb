require 'bundler/capistrano'
require 'bcdatabase'

require "whenever/capistrano"
set :whenever_command, "bundle exec whenever"

# Using the bcdatabase gem for server config
deploy_file = ENV['STUDY_CENTER'] || "ncs"
bcconf = Bcdatabase.load["#{deploy_file}_deploy", :ncs_staff_portal]
set :application, "ncs_staff_portal"

# User
set :use_sudo, false
ssh_options[:forward_agent] = true

# Version control
default_run_options[:pty]   = true # to get the passphrase prompt from git

set :scm, "git"
set :repository, bcconf["repo"]
set :branch do
  # http://nathanhoad.net/deploy-from-a-git-tag-with-capistrano
  puts
  puts "Tags: " + `git tag`.split("\n").join(", ")
  puts "Remember to push tags first: git push origin --tags"
  ref = Capistrano::CLI.ui.ask "Tag, branch, or commit to deploy [master]: "
  ref.empty? ? "master" : ref
end
set :deploy_to, bcconf["deploy_to"]
set :deploy_via, :remote_cache

# Roles
task :set_roles do
  role :app, app_server
  role :web, app_server
  role :db, app_server, :primary => true
end

# Staging environment
desc "Deploy to staging"
task :staging do
  set :app_server, bcconf["staging_app_server"]
  set :rails_env, "staging"
  set_roles
end

# Demo environment
desc "Deploy to Demo"
task :demo do
  set :app_server, bcconf["demo_app_server"]
  set :rails_env, "staging"
  set_roles
end

# Production environment
desc "Deploy to production"
task :production do
  set :app_server, bcconf["production_app_server"]
  set :rails_env, "production"
  set :whenever_environment, fetch(:rails_env)
  set_roles
end

# Deploy start/stop/restart
namespace :deploy do
  desc "Restarting passenger with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end

  desc "Fix permissions"
  task :permissions do
    unless ENV['NO_FIX_PERMISSIONS']
      sudo "chmod -R g+w #{shared_path} #{release_path}"
    end
  end

  task :setup_import_directories do
    unless ENV['NO_IMPORT_DIRECTORY']
      shared_import  = File.join(shared_path,  'importer_passthrough')
      release_import = File.join(release_path, 'importer_passthrough')
      cmds = [
        "mkdir -p '#{shared_import}'",
        # Only chmod if owned; this is the only case in which chmod is
        # allowed. Will be owned if just created, which is the important
        # case.
        "if [ -O '#{shared_import}' ]; then chmod g+w '#{shared_import}'; fi",
        "if [ ! -e '#{release_import}' ]; then ln -s '#{shared_import}' '#{release_import}'; fi"
      ]
      run cmds.join(' && ')
    end
  end
end

# backup the database before migrating
# before 'deploy:migrate', 'db:backup'

# after deploying, generate static pages, copy over uploads and results, cleanup old deploys,
# aggressively set permissions, copy images to current image config location.
after 'deploy:update_code', 'deploy:cleanup', 'deploy:permissions', 'config:images', 'deploy:setup_import_directories'

# Database
namespace :db do
  desc "Backup Database"
  task :backup, :roles => :app do
    run "cd #{current_path} && rake RAILS_ENV=#{rails_env} db:backup"
  end

  desc "Seed Data"
  task :seed, :roles => :app do
    run "cd #{current_path} && bundle exec rake RAILS_ENV=#{rails_env} db:seed"
  end
end

namespace :config do
  desc "Copy configurable images to /public/images/config folder"
  task :images,  :roles => :app do
    run "cd #{release_path} && bundle exec rake RAILS_ENV=#{rails_env} config:images"
  end
end
