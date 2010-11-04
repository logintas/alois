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

module ActiveRecord
  module ConnectionAdapters
    class MysqlAdapter

      def auto_increment(table_name)
	begin
	  res = execute("SHOW TABLE STATUS LIKE '#{table_name}'") 	
	  res.fetch_hash['Auto_increment'].to_i
	rescue ActiveRecord::Transactions::TransactionError
	  raise $!
	end
      end
      
      def flush_tables
	execute("flush tables")
      end
      
      def approx_count(table_name)
	begin
	  res = execute("SHOW TABLE STATUS LIKE '#{table_name}'")
	  res = res.fetch_hash
	  return nil unless res
	  a_count = res['Rows'].to_i
	rescue ActiveRecord::Transactions::TransactionError
	  raise $!
	end
      end
      
      def current_queries
	ret = []
	res = execute("SHOW FULL PROCESSLIST")
	while col = res.fetch_hash
	  ret.push(col)
	end
	return ret
      end

      def kill(query_id)
	execute("KILL #{query_id.to_i}")
      end

      def innodb_status
	execute("SHOW INNODB STATUS").fetch_hash["Status"]
      end
      
      def variables_text
	hash = {}
	res = execute("SHOW VARIABLES")
	while col = res.fetch_hash
	  hash[col["Variable_name"]] = col["Value"]
	end
	ml = hash.keys.map {|k| k.length}.max
	
	hash.keys.sort.map {|key| key.ljust(ml," ") + ": " + hash[key].to_s }.join("\n")
      end
    end
  end
end
