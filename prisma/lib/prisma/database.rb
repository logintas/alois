# Copyright 2010 The Apache Software Foundation.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
module Prisma
    # based on .gem/ruby/1.8/gems/rails-2.3.2/lib/tasks/databases.rake 

  class Database
    PRISMA_DBS = ["prisma","pumpy"]
    def Database.load_all(options = {})
      PRISMA_DBS.each {|db_name| 
        Prisma::Database.load_classes(db_name, options)
      }
    end

    def self.config_path; PRISMA_CONFIG_PATH; end
    def self.data_path; PRISMA_DATA_PATH; end
    
    def self.normalize_config(db_root, config)
      ret = {}
      config.each {|key,val|
        ret[key.to_s] = val.to_s
      }
      if ret["adapter"] =~ /sqlite/ and !Pathname.new(ret["database"]).absolute?
        ret["database"] = (db_root + config["database"])
        ret["database"] = (ret["database"].dirname.realpath + ret["database"].basename).to_s
      end
      ret
    end
    
    def self.db_config(db_name, options = {})
      @@configs ||= {}
      return @@configs[db_name] if @@configs[db_name] and !options[:reload]

      config_file = config_path + "#{db_name}_database.yml"
      $log.debug("Loading connection #{db_name}[#{PRISMA_ENV.inspect}] from #{config_file}")
      config = YAML::load(config_file.open("r"))[PRISMA_ENV]

      if user = options[:force_user]
        $log.info("Forcing user #{user}")
        config["password"] = $ui.password("Overriding accessing user.\nPlease enter password of #{user} for db #{db_name}:")
        config["username"] = options[:force_user]
      end

      $log.debug("Connection #{db_name}: #{config.inspect}")

      @@configs[db_name] = normalize_config(data_path, config)
      return @@configs[db_name]
    rescue
      raise "Error loading db config #{db_name} from #{config_file}: #{$!}"
    end
    
    def self.connection_name(klass)
      base_config = normalize_config(Pathname.pwd, klass.connection_pool.spec.config)
      
      ActiveRecord::Base.configurations.each {|name, config|
        config = normalize_config(Pathname.pwd, config)
        return name.to_s if base_config == config
      }
      return nil
    end
    
    def self.with_db(db_name = nil, options = {})
      load_connection(db_name, options) if db_name
      
      old_pool = ActiveRecord::Base.connection_handler.connection_pools["ActiveRecord::Base"]
              
      begin
        ActiveRecord::Base.establish_connection(db_name) if db_name
        yield        
      ensure
        # use the origin connetion again
        ActiveRecord::Base.connection_handler.connection_pools["ActiveRecord::Base"] = old_pool
      end
    end

    def self.connection_pool(db_name)
      ActiveRecord::Base.connection_handler.connection_pools[db_name]
    end
    def self.connection(db_name)
      pool = connection_pool(db_name)
      pool.connection if pool
    end

    def self.reconnect
      PRISMA_DBS.each {|db|
        $log.debug("Reconnecting #{db}")
        p = self.connection_pool(db)
        unless p
          $log.debug("No pool for#{db} found")
          next 
        end
        p.disconnect!
        p.with_connection {}
      }
    end

    def self.check_connections(options = {})
      PRISMA_DBS.reject {|db| check_connection(db)}.length == 0
    end

    def self.check_connection(db_name, options = {})
      c = connection(db_name)
      return true unless c
      c.verify!
      return true
    rescue
      $log.warn("Connection #{db_name} does not work")
      return false
    end
    
    def self.migrate_path(db_name)
      self.data_path + "#{db_name}_database/migrate"
    end
    def self.migrate(db_name, version = nil, options = {})
      with_db(db_name, options) {
        #system("ls data/prisma/#{db_name}_database/migrate")

        if options[:redo]
          ActiveRecord::Migrator.rollback(migrate_path(db_name), options[:redo])
        end
        ActiveRecord::Migrator.migrate(migrate_path(db_name), version )
      }
    end
    
    def self.schema(db_name)
      self.data_path + "#{db_name}_database/schema.rb"
    end
    def self.schema_load(db_name, options = {})
      with_db(db_name, options) {
        load(schema(db_name).to_s)
      }
    end
    def self.schema_dump(db_name, options = {})
      with_db(db_name) {
        require 'active_record/schema_dumper'
        File.open(schema(db_name).to_s, "w") do |file|
          ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
        end
      }
    end
    def self.check(db_name, options = {})
      with_db(db_name, options) {
        pending_migrations = ActiveRecord::Migrator.new(:up, migrate_path(db_name)).pending_migrations
        
        if pending_migrations.any?
          puts "You have #{pending_migrations.size} pending migrations:"
          pending_migrations.each do |pending_migration|
            puts '  %4d %s' % [pending_migration.version, pending_migration.name]
          end
          raise "Pending migrations"
        else
          $log.info("No pending migrations for #{db_name}")
        end        
      }
    end
    
    def self.load_connection(db_name, options = {})
      return if ActiveRecord::Base.configurations[db_name] 
      spec = self.db_config(db_name, options)
      ActiveRecord::Base.configurations[db_name] = spec
      
      with_db {
        ActiveRecord::Base.establish_connection(db_name)
        new_pool = ActiveRecord::Base.connection_pool        
        ActiveRecord::Base.connection_handler.connection_pools[db_name] = new_pool
      }
      
      # if alois is available register this connection
      if defined?(RAILS_ENV)
        spec = {"name" => db_name}.update(spec).symbolize_keys
        spec.delete(:reconnect)
        conn = Connection.new(spec)
        conn.register
      end
    end
    
    def self.load_classes(db_name, options = {})
      load_connection(db_name, options)
      #      migrate(db_name)
      @@classes ||= {}
      @@classes[db_name] = []
      
      Pathname.glob(data_path + "#{db_name}_database/model/*.rb").each {|file|
        $log.debug("Requiring #{file.to_s}")
        require file.to_s        
        
        class_name = file.basename.to_s[0..-4].camelize
        
        $log.debug("Loading #{class_name}")
        klass = eval(class_name)
        
        ActiveRecord::Base.connection_handler.connection_pools[klass.name] =
          ActiveRecord::Base.connection_handler.connection_pools[db_name]
        
        @@classes[db_name] << klass unless @@classes[db_name].include?(klass)
        #establish_connection "db1"    
      }
    end
    
    def self.get_classes(type = nil)
      return @@classes.values.flatten if type.nil?
      case type
      when String
        @@classes[type]        
      when :raw
        return [] unless @@classes["pumpy"]
        @@classes["pumpy"].select {|c| c.name =~ /Raw$/ }
      when :meta
        return [] unless @@classes["prisma"]
        @@classes["prisma"].select {|c| c.name =~ /Meta$/ }
      when :message
        return [] unless @@classes["prisma"]
        @@classes["prisma"].select {|c| c.name =~ /Message$/ }
      else
        raise "Called get_classes with unexpected argument #{type.inspect}"
      end
    end
    
    # Returns all possible datasources. (Views + Alois Classes)
    def Database.data_sources
      (View.find(:all) + get_classes)
    end
    
    # Returns the class from tablename, it the table
    # is not one of alois base classes return nil.
    def Database.get_class_from_tablename(tablename)
      return nil unless tablename
      name = tablename.singularize.camelize
      for klass in get_classes
        return klass if klass.name == "#{name}"
      end
      return nil
    end

    # Delete SourceMeta, record is a sourcemeta object,
    # dryrun lists all records that sould be deleted.
    def self.delete_source(record,dryrun)
      if dryrun
        childr = record.children_recursive
        $log.info("Would delete: #{record.to_s} with #{childr.length} children")
        if $log.debug?
          childr.map{|c| "#{c.id}.#{c.class.name}"}.each {|c|
            $log.debug("  with child: #{c}")
          }
        end
      else
        $log.info("Deleting: #{record.to_s}")
        Prisma::Database.speed_transaction(record) {
          record.prisma_destroy
        }
        #	record.children_recursive.each {|c|
        #	  c.destroy
        #	}
        #	record.destroy
        #      end
      end
    end
    
    # Remove logs before the given date. Action may be :all, :database or :archive.
    # See delete-old-logs script for more information.
    def self.delete_logs_before(action, date, dryrun = false)
      # disable transaction because too much
      # data concerned
      old_adt = $alois_disabled_transaction
      $alois_disabled_transaction = true
      $log.info("Commiting #{$transaction_bundle_amount} operations together")
      
      if action == :all or action == :database
        ArchiveMeta.find(:all, :conditions => [ "created_at < :date", {
                                                  :date => date}]).each {|record|
          delete_source(record,dryrun)
        }
        
        SourceDbMeta.find(:all, :conditions => [ "created_at < :date", {
                                                   :date => date}]).each {|record|
	  delete_source(record,dryrun)
        }
      end
      
      if action == :all or action == :archive
        # old archive
        Dir.glob("/var/lib/prisma/archive/old*/*").each {|file|
          mtime = File.mtime(file).strftime("%F")
          if mtime  < date then
            if dryrun
              $log.info("Would delete: '#{file}' with mtime #{mtime}.")
            else
              $log.info("Deleting file '#{file}' with mtime #{mtime}.")
              begin
                File.delete(file)
              rescue ActiveRecord::Transactions::TransactionError
                raise $!
              rescue
                $log.error("Could not delete '#{file}': #{$!.to_s}")
              end
            end
          end	
        }
        
        # new archive
        files = Dir.glob($archive_pattern.to_s.gsub(/\%./,"*"))
        files += Dir.glob($archive_pattern.to_s.gsub(/\%./,"*") + ".gz")
        
        archive_root = nil
        if $archive_pattern.to_s =~ /^([^\%]*\/)\%/
          archive_root = Pathname.new($1).realpath.to_s
        else
          throw "Could not get root of archive_path."
        end
        
        regex =  Regexp.new(Regexp.escape($archive_pattern.to_s).gsub(/\%i/,"([^\/]*)").gsub(/\%./,"[^\/]*") + "(\.gz)?")
        files.each {|file|
          if file =~ regex
            if $1 < date then
              if dryrun
                $log.info("Would delete: '#{file}' with incoming date #{$1}.")
              else
                $log.info("Deleting: '#{file}' with incoming date #{$1}.")
                begin
                  File.delete(file)
                  
                  dir = Pathname.new(file).parent.realpath.to_s	      
                  while Dir.glob(dir + "/*").length == 0 and not dir == archive_root
                    # directory empty delete
                    $log.info("Removing emtpy dir '#{dir}'.")
                    Dir.rmdir(dir)
                    dir = Pathname.new(dir).parent.realpath.to_s
                  end
                rescue ActiveRecord::Transactions::TransactionError
                  raise $!
                rescue
                  $log.error("Could not delete '#{file}': #{$!.to_s}")
                end
                
              end	    
            end
          else
            $log.error("Could not determine incoming date of file '#{file}'.")
          end
        }

        #	cmd = "/usr/bin/find #{archive_root} -type d -empty -exec rmdir {} \\;"
        #	if dryrun
        #	  $log.info("Cleaning up. Would delete emtpy directories in '#{archive_root}'")
        #	  $log.info("Would execute: '#{cmd}'")
        #	else
        #	  $log.info("Cleaning up. Deleting emtpy directories in '#{archive_root}'")
        #	  $log.info("Exec '#{cmd}'")
        #	  exec(cmd)
        #	end
        #      else
        #	$log.error("Could not get root archive path.")
        #      end
        
      end
      $alois_disabled_transaction = old_adt    
    end

    def Database.delete_from_id(source_class, id, options = {})
      return unless id
      $log.info("Going to delete from #{source_class.name} id <= #{id}")
      options = {:recursive => true, :dryrun => true}.update(options)
      
      if options[:recursive]
        if source_class != Message
          msg_cond = "meta_id <= #{id} and meta_type_name = 'Prisma::#{source_class}'"
          $log.info("Looking for messages #{msg_cond}")
          msg = Message.find(:first, :order => "id DESC", :conditions => msg_cond)
          if msg
            delete_from_id(Message, msg.id, options)
          end
        end
        
        fc = source_class.foreign_column_name
        possible_classes = Prisma.get_classes(:meta).
          map {|c| eval(c.name)}.
          select {|c| c.column_names.include?(fc)}
        
        possible_classes.each {|klass|
          $log.info("Looking for #{klass.name} #{fc} <= #{id}")
          
          first_smaller_object = klass.find(:first, 
                                        :conditions => ["#{fc} IS NOT NULL and #{fc} <= #{id}"],
                                            :order => ["#{fc} desc"])
          if first_smaller_object.nil?
            $log.info("No logs found for #{klass.name}")
            next
          end
          delete_from_id(klass, first_smaller_object.id,options)
        }
      end
      
      delete_condition = "id <= #{id}"
      txt = "#{source_class.name} (#{delete_condition})"
      delete_count = nil
      if options[:count]
        # the condition that foreign_key_column may not be 
        # null should be reflected here too, but at the moment
        # this makes not difference because we always have only one
        # path from log meta to any child table
        
        $log.info("Counting #{source_class} id <= #{id}")
        delete_count = source_class.count(:all, :conditions => delete_condition)
        $log.info("Counting #{source_class} :all")
        all = source_class.approx_count
        txt = "%.2f perc. (#{delete_count} of #{all}) #{source_class.name} (#{delete_condition})" % (100.0/all*delete_count)
      else
        
      end

      if options[:dryrun]
        $log.info("Would delete #{txt}")
      else
        $log.info("Delete #{txt}")
        limit = 100000
        sql = "DELETE FROM #{source_class.quoted_table_name} WHERE #{delete_condition} LIMIT #{limit}"
        count = 1
        total_count = 0
        
        if delete_count
          
          $ui.progress_bar(source_class.name, delete_count) {
            while count > 0
              count = source_class.connection.delete(sql, "#{source_class.name} delete all #{delete_condition} limit #{limit}")
              total_count += count
              $ui.progress(total_count)          
              # $log.info("Deleted #{count} #{delete_condition} (%.2f perc. #{total_count}/#{delete_count})" % (100.0/delete_count*total_count))
            end
          }
        else
          while count > 0
            count = source_class.connection.delete(sql, "#{source_class.name} delete all #{delete_condition} limit #{limit}")
            
            total_count += count
            $log.info("Deleted #{count} #{delete_condition} (total deleted #{total_count})")
          end
        end
      end
      
    end

    def Database.quick_and_dirty_db_delete(before_date,dryrun=false)

      options = {
        :dryrun => dryrun,
        :count => $log.info?,
        :recursive => true,
      }
      
      #      ActiveRecord::Base.connection.reconnect!
      klass = LogMeta
     
      days = nil
      while days.nil? or days.length > 1
        days = []
        days_res = klass.connection.execute("SELECT date,min(id),count(*) FROM log_metas WHERE date < '#{before_date}' GROUP BY date ORDER BY date LIMIT 2")
        days_res.each {|d| days << d}
        $log.debug(days.inspect)
        break if days.length <=1        

        from_date = days[-1][0]
        id = days[-1][1]
        count = days[-1][2]        

        $log.info("Processing #{from_date} (#{count}x#{klass.name})")
        from_object = (LogMeta.find(id) rescue nil)
        if from_object
          #    delete_from_id(LogMeta, from_object.id, options)         
          LogMeta.column_names.map {|c| c=~ /^(.*_metas)_id$/; $1 }.compact.map {|c| eval c.classify}.each {|parent|
            from_id = from_object.send(parent.foreign_column_name)
            delete_from_id(parent, from_id, options.dup.update(:recursive => false))
          }
        end
      end
    end
    
    def Database.transaction(klass = nil)
      klass ||= ActiveRecord::Base
      if $alois_disabled_transaction
        yield
      else
        $log.debug("Begin transaction on #{klass.name}")
        klass.transaction do 
          yield
        end
        $log.debug("End transaction on #{klass.name}")
      end
    end
    
  # Returns all classes that can transform messages (classes with parsing functionality)
  def Database.transformer_classes(klass)
    classes = get_classes(:meta).select { |meta_klass|
      meta_klass.can_transform?(klass)
    }
    $log.debug{"Transformer classes for class #{klass}: #{classes.map {|c| c.name}.inspect}"}
    classes
  end
  
  def Database.speed_transaction_enabled
    # disabled, becaus does not work with sqlite
    false # $alois_disabled_transaction
  end
  # the idea here is to pack some sql calls
  # together with transactions and call commit
  # after eg 500 calls, so the cost of the
  # individual commits are "packed together"
  def Database.speed_transaction(klass = nil)
    unless Prisma::Database.speed_transaction_enabled
      # other transactions are used, this
      # implementation cannot handle that
      yield
      return
    end

    # default settings
    klass ||= ActiveRecord::Base
    $transaction_bundle_amount ||= 500
    
    # for easier writing
    tb = $transaction_bundle
    unless tb
      $log.debug{"Initialize transaction bundle"}
      # this is the first call of speed_transaction
      $transaction_bundle = {
	:connection => klass.connection,
	:count => 0,
	:yields => 0,
	:open_transaction => false
      }
      tb = $transaction_bundle
    else
      $log.debug{"Transaction bundle connections are equal: #{tb[:connection] == klass.connection}"}
      # check if the transaction is on the same 
      # connection, if not, return
      unless tb[:connection] == klass.connection
 	yield
	return
      end
    end
    
    unless tb[:open_transaction]
      $log.debug("No transaction open for bundle, open one")
      # start transaction if none is open
      tb[:connection].send(:begin_db_transaction) 
      tb[:count] = 0
      tb[:start_time] = Time.now
      tb[:open_transaction] = true
    end
    
    tb[:count] += 1
    tb[:yields] += 1
    yield
    tb[:yields] -= 1
    
    if tb[:open_transaction] and (tb[:count] >= $transaction_bundle_amount or 
	tb[:yields] == 0)
      tb[:connection].commit_db_transaction
      
      if $destroy_calls_speed
	$destroy_calls ||= 0
	$destroy_calls += $destroy_calls_speed 
	$destroy_calls_speed = 0
      end	
      
      tb[:open_transaction] = false
      duration = Time.now - tb[:start_time]
      Prisma::Util.perf{"speed_transaction: Had #{duration}s for #{tb[:count]} (#{tb[:count].to_f/duration} per sec)"}
    end
    
    if tb[:yields] == 0
      # this is the last call of speed
      # transactions, reset global var
      # and tidy up
      # ps: transaction sould already be
      #     commited above
      raise "Transaction not yet commited" if
	tb[:open_transaction] 
      $transaction_bundle = nil
    end
  end

  end
end
