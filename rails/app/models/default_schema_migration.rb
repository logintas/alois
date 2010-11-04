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

  class DefaultSchemaMigration < ActiveRecord::Base
    set_table_name "schema_migrations"
    
    def self.version
      self.find(:all).sort_by {|m| m.version.to_i}[-1].version.to_i
    end

    def self.dump_schema_version
      open(schema_version_file,"w").write(self.version)
    end

    def self.schema_version_file(db = nil)
      db = ENV['DEFAULT_CONNECTION'] unless db
      "#{RAILS_ROOT}/app/models/packaged_for_#{db}_schema_version"
    end

    def self.desired_version_from_dump_file(db)
      return nil unless File.exists?(schema_version_file(db))
      open(schema_version_file(db),"r").read().to_i
    end
    
    def self.desired_version_from_migration_files(db)
      Dir.glob("#{RAILS_ROOT}/db_#{db}/migrate/*.rb").sort.reverse.each { |f|
	if Pathname.new(f).basename.to_s =~ /^(\d\d\d)_.*\.rb$/
	  return $1.to_i
	end
      }
      return nil
    end

    def self.check_schema_versions!
      check_schma_version!("alois")
      check_schma_version!("pumpy")
    end

    def self.check_schma_version!(db)
      desired_version = desired_version_from_dump_file(db) 
      desired_version = desired_version_from_migration_files(db) unless desired_version

      throw "Could not get the desired db version for database #{db}!" unless desired_version
      case db
      when "alois"
	current_version = AloisSchemaMigration.version	
      when "pumpy"
	current_version = PumpySchemaMigration.version
      else
	throw "No such database '#{db}'."
      end
      
      if current_version == desired_version 
	$log.info{"Database version for db '#{db}' match! (curr: '#{current_version}', desired: '#{desired_version}')"}
      else
	msg = "Database version mismatch for db '#{db}'! (curr: '#{current_version}', desired: '#{desired_version}')"
	$log.error{msg}
	throw msg
      end	
    end
  end
