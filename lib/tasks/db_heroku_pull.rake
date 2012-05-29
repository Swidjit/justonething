namespace :db do
  namespace :heroku do
    task :pull => :environment do
      filename = 'tmp/latest.dump'

      puts "\nDownloading latest db backup into #{filename} . . .\n"
      puts "WARNING: If download does not commence momentarily, run `heroku auth:login` and try again\n\n"
      puts `curl -o #{filename} $(heroku pgbackups:url)`

      config = Rails.configuration.database_configuration[Rails.env]
      settings = "#{config['host'].present? ? '-h localhost' : ''} -U #{config["username"]} -d #{config["database"]}"

      puts "Restoring db with settings: #{settings} . . .\n"
      %x(pg_restore --verbose --clean --no-acl --no-owner #{settings} #{filename} 2> /dev/null)
      if ($? == 0)
        puts "Retore was successful, removing #{filename}"
        %x(rm #{filename})
      else
        puts "Restore failed.  pg_restore #{$?}"
      end
    end
  end
end
