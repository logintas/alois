namespace "alois" do

  desc "Freeze all gems"
  task :freeze => :environment do
    Rails.configuration.gems.each {|g| 
	ENV["GEM"] = g.name
	Rake::Task["gems:freeze"].execute
	Rake::Task["gems:link"].execute
    }
  end

  namespace :db do

    desc "Dumps the schema version."
    task :dump_schema_version => :environment do
	DefaultSchemaMigration.dump_schema_version
    end

    desc "Check schema version."
    task :print_schema_version => :environment do
	begin 
	  config = Rails::Configuration.new.database_configuration[RAILS_ENV]
	  DefaultSchemaMigration.check_schma_version!(config['database'])
	  print "VERSION: #{DefaultSchemaMigration.version}\n"	  	  
	rescue
	  print "#{$!}\n"
	  case $!.to_s 
	  when /mismatch/
	    exit 2
	  when /Unknown database/
	    exit 3
	  when /'mysql.schema_migrations' doesn't exist/
	    exit 4
	  else	    
	    exit 1
	  end
	end
    end
    
    desc "Creates the database only. (no structure)"
    task :create => :environment do
	config = Rails::Configuration.new.database_configuration[RAILS_ENV]
        connection = connect_mysql_local
	connection.query("CREATE DATABASE #{config['database']}")
    end

    desc "Drops the database"
    task :drop => :environment do
	config = Rails::Configuration.new.database_configuration[RAILS_ENV]
	print "Will drop database '#{config['database']}' on '#{config['host']}'."
	[3,2,1,0].each { |n|
	  print(" #{n} ")
	  STDOUT.flush
	  sleep(1)
	}
	print "\n"
        connection = connect_mysql_local
	connection.query("DROP DATABASE #{config['database']}")
    end

    desc "Prints out the current selected default database."
    task :print_database => :environment do
	config = Rails::Configuration.new.database_configuration[RAILS_ENV]
	print "The current connection is: '#{config['database']}' on '#{config['host']}'\n"
    end

    desc "Removes the default databse - no rails database tasks can be performed anymore."
    task :undefine_db do
      File.delete('db') if File.symlink?('db')
      File.delete('test/fixtures') if File.symlink?('test/fixtures') 
    end

    desc "Defines that the default connection points to the pumpy database."
    task :set_pumpy_db => :undefine_db do
      File.symlink('db_pumpy','db')
      File.symlink('fixtures_pumpy','test/fixtures') if File.directory?('test')
    end

    desc "Defines that the default connection points to the alois database."
    task :set_alois_db => :undefine_db do
      File.symlink('db_alois','db')
      File.symlink('fixtures_alois','test/fixtures') if File.directory?('test')
    end

    desc "Compares the current database schema to the 'should be' schema."
    task :compare_schema => :environment do
      # dump the actual schema to
      File.copy("db/expected_schema.rb","db/schema.rb") if File.exist?("db/expected_schema.rb")
      ENV['SCHEMA'] = "db/current_schema.rb"
      Rake::Task["db:schema:dump"].invoke
	
      difference = false

      # compare the 
      open("|/usr/bin/diff -w -u db/schema.rb db/current_schema.rb").each { |line|
	print line
        difference = true
      }		

      # remove dumped schema file
      File.delete("db/current_schema.rb")
     
      throw "Current db has not the proper schema." if difference
    end

    desc "Creates the schema dump file from the migration scripts."
    task :create_schema do
	ENV['RAILS_ENV'] = 'test'
	RAILS_ENV = 'test'
        Rake::Task["environment"].invoke
        Rake::Task["db:test:purge"].invoke
	ActiveRecord::Base.connection.reconnect!
        Rake::Task["db:migrate"].invoke
        Rake::Task["db:schema:dump"].invoke
    end

  end
end