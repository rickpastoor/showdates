# frozen_string_literal: true

require 'mina/bundler'
require 'mina/deploy'
require 'mina/git'
require 'mina/rbenv'

set :application_name, 'showdates.me'
set :domain, 'beta.showdates.me'
set :user, 'rick'
set :deploy_to, '/var/www/showdates.me'
set :repository, 'git@github.com:rickpastoor/showdates'
set :branch, 'master'

set :shared_files, fetch(:shared_files, []).push('.env').push('public/uploads')

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :remote_environment do
  invoke :'rbenv:load'
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  command %(gem install bundler -v '< 2.0')
end

namespace :cron do
  task install: :remote_environment do
    comment 'Creating cron jobs'

    in_path(fetch(:current_path)) do
      cronjobs_file = "#{fetch(:deploy_to)}/$build_path/crontabs"
      command %(cat #{cronjobs_file} | crontab -)
    end
  end
end

desc 'Deploys the current version to the server.'
task :deploy do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  # invoke :'git:ensure_pushed'
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    command 'RAKE_ENV=production bundle exec rake db:migrate'
    invoke :'cron:install'
    invoke :'deploy:cleanup'

    on :launch do
      in_path(fetch(:current_path)) do
        # command %(bundle exec thin restart -C /etc/thin/showdates.me.yml)
        # command %(sudo systemctl restart sidekiq)
      end
    end
  end
end
