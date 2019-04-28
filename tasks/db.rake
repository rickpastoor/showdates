# frozen_string_literal: true

namespace :db do
  desc 'Generate a new date-based, empty Sequel migration.'
  task :migration, :name do |_, args|
    if args[:name].nil?
      puts 'You must specify a migration name ' \
           '(e.g. rake db:migration[create_events])!'
      exit false
    end

    content = "# frozen_string_literal: true\n\n" \
              "Sequel.migration do\n  change do\n    \n  end\nend\n"
    timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    filename = File.join('db', 'migrations', "#{timestamp}_#{args[:name]}.rb")

    File.write(filename, content)

    puts "Created the migration #{filename}"
  end

  desc 'Run migrations.'
  task :migrate do
    require_relative '../lib/setup'
    Sequel.extension :migration

    puts 'Migrating to latest'
    Sequel::Migrator.run(DB, 'db/migrations')
  end
end
