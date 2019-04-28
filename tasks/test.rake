# frozen_string_literal: true

# require 'rubocop/rake_task'
# require 'rake/testtask'
# require 'cucumber'
# require 'cucumber/rake/task'
#
# namespace :test do
#   Rake::TestTask.new(:spec) do |t|
#     t.libs << 'spec'
#     t.test_files = FileList['spec/**/*_spec.rb']
#     t.verbose = true
#     t.warning = false
#   end
#
#   Cucumber::Rake::Task.new(:features) do |task|
#     task.cucumber_opts = %w[features --strict --format pretty --order random]
#   end
# end
#
# RuboCop::RakeTask.new(:rubocop) do |task|
#   task.options = %w[--display-cop-names --display-style-guide --extra-details]
# end
#
# desc 'Run all tests'
# task test: %w[test:spec test:features rubocop]
