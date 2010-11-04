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

  # Model for storing anonymized information ids.
  # /!\
  # This implementation is not yet productive and does
  # not yet work really!!!
  # /!\
  # Example: Nonym.anonymize_column(LogMeta)
  class Nonym < ActiveRecord::Base

#    description "Nonym information"

    # Find or create a new name to be anonymized
    def self.find_or_create(realname)
      record = self.find_by_real_name(realname)
      if not record
	$log.info("Nonym #{realname} not found - creating.") if $log.info?
	record = self.new()
	record.real_name = realname
	record.save
      end
      return record
    end
       
    # Anonymize a whole column. /!\ This change will not be reflected
    # in schema.rb, so any later migration could fail.
    def self.anonymize_column(klass, column)
      $log.debug("Anonymize column #{column} in table #{klass.table_name}.")
      begin	
	klass.connection.add_column(klass.table_name, "#{column}_anonym", :integer)
	klass.connection.add_index(klass.table_name, "#{column}_anonym")
	total = klass.count()
	start = DateTime.now
	curr = 0
	out = false
	for record in klass.find(:all)	  
	  if ((DateTime.now - start).to_i % 5) == 0
	    $log.info("#{(100/total*curr).to_i}\%") if $log.info? and not out
	    out = true
	  else
	    out = false
	  end
	  record.send("#{column}_anonym=", Nonym.find_or_create(record.send(column)).id)
	  record.save
	  curr = curr + 1
	end
	$log.info("100\%") if $log.info?
	$log.debug("Done total #{total} in #{(DateTime.now - start).to_i} seconds.") if $log.info?
      rescue TransactionError
	raise $!
      rescue	     
	connection.remove_column(klass.table_name,"#{column}_anonym")
	throw $!
      end
      connection.remove_column(klass.table_name, "#{column}")
    end
    
    # Revert anonymized column. The column must be without _anonym ending.
    def self.nonymize_column(klass, column, limit, with_index)
      $log.debug("Nonymize column #{column} in table #{klass.table_name}.")
      begin
	klass.connection.add_column(klass.table_name, "#{column}", :string, :limit => limit)
	klass.connection.add_index(klass.table_name, "#{column}") if with_index
	total = klass.count()
	start = DateTime.now
	curr = 0
	out = false
	for record in klass.find(:all)	  
	  if ((DateTime.now - start).to_i % 5) == 0
	    $log.info("#{(100/total*curr).to_i}\%") if $log.info? and not out
	    out = true
	  else
	    out = false
	  end
	  nonym = Nonym.find(record.send("#{column}_anonym"))
	  record.send("#{column}=",nonym.real_name)
	  record.save
	  curr = curr + 1
	end
	$log.info("100\%") if $log.info?
	$log.debug("Done total #{total} in #{(DateTime.now - start).to_i} seconds.") if $log.info?
      rescue TransactionError
	raise $!
      rescue	     
	klass.connection.remove_column(klass.table_name, "#{column}")
	throw $!
      end
      klass.connection.remove_column(klass.table_name, "#{column}_anonym")
    end
  end

