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

# This mixin includes all mysql specific
# functions. Here you can override the
# class and instance methods.
# 
# /!\ This implementation does not work correct yet. /!\
# TOOD: Finish nonym implementation
module MysqlMixin

  module ClassMethods

    # returns the current auto_increment value of the table
    def auto_increment
      connection.auto_increment(self.table_name)
    end
    
    # Returns table status information of the table
    def read_db_status(status_name)
      res = connection.execute("SHOW STATUS")
      res.each_hash {|h|
	return h["Value"] if h["Variable_name"].downcase == status_name.downcase
      }
      raise "Status with name #{status_name} not found."
    end

    # "reload" table informations
    def flush_tables
      connection.flush_tables
    end

    # Compute a approximate count of the table. This is useful for
    # slow innodb counts and computed out of table status information.
    # If approx count is below 20000, a exact count will be returned.
    def approx_count
      return count unless connection.respond_to?(:approx_count)
      a_count = connection.approx_count(self.table_name)
      return a_count unless a_count
      if a_count < 20000
	count
      else
	a_count
      end
    end

  end
  
  module InstanceMethods
  end
  
  def self::included other
    other.module_eval  { include InstanceMethods }
    other.extend ClassMethods
    
    other
  end
   
end
