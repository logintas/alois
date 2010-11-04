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

class Connection < ActiveRecord::Base
  @@connections = {}
  def Connection.connections; @@connections; end

  def Connection.activerecord_connection(name)
    conn = @@connections[name]
    raise "Connection with name #{name} not registered" unless conn
    conn.activerecord_connection
  end

  def Connection.from_name(name)
    @@connections[name]
  end

  def Connection.from_pool(pool)
    @@connections.each {|name, connection|
      return connection if connection.pool == pool
    }
    return nil
  end

  def Connection.register(conn)
    @@connections[conn.name] = conn
  end

  attr_accessor :pool

  def activerecord_connection
    raise "Connection #{name} ont yet registered" unless @pool
    @pool.connection
  end

  def spec
    self.attributes.symbolize_keys    
  end

  def connection_handler
    ActiveRecord::Base.connection_handler
  end
  
  def register
    raise "Already registered connection #{name}" if @pool
    raise "Connection #{name} already registered globally" if @@connections[name]

    @pool = connection_handler.establish_connection(name, ConnectionSpecification.new(spec, "#{spec[:adapter]}_connection"))
    Connection.register(self)
  end

  def unregister
    raise "Connection #{name} not registered" unless @pool

    # compare connection pool
    connection_pools = connection_handler.connection_pools
    other_connections = connection_pools.select { |key, value| 
      value == @pool 
    }.map {|key,value| key}

    raise "Connection #{name} not in connection pool!" if other_connections.length == 0
    raise "Other klasses need this connection #{other_connections}" if
      other_connections.length > 1    

    connection_pools.delete_if {|key,value| value == @pool}
    @pool.disconnect!
#    conf = @pool.spec.config
    @pool = nil
#    conf
  end
  
  def status
    case adapter
    when "mysql"
      execute("SHOW INNODB STATUS").fetch_hash["Status"]      
    when /sqlite/
    else
      "No status available for adapter #{adapter}"
    end
  end

  def execute(sql)
    activerecord_connection.execute(sql)
  end

  def auto_increment(table_name)
    connection_auto_increment(activerecord_connection, table_name)
  end
    
  # old mysql function
  # def flush_tables
  #   execute("flush tables")
  # end
  def approx_count(table_name)
    connection_approx_count(activerecord_connection, table_name)
  end
  
  def current_queries
    case adapter
    when "mysql"
      ret = []
      res = execute("SHOW FULL PROCESSLIST")
      while col = res.fetch_hash
        ret.push(col)
      end
      return ret
    else
      return nil
    end
  end

  def kill(query_id)
    case adapter
    when "mysql"
      execute("KILL #{query_id.to_i}")
    else
      raise "Kill queries not implemented for #{adapter}"
    end
  end
      
  def variables_text
    hash = {}
    case adapter
    when "mysql"      
      res = execute("SHOW VARIABLES")
      while col = res.fetch_hash
        hash[col["Variable_name"]] = col["Value"]
      end
      ml = hash.keys.map {|k| k.length}.max
    else
    end

    hash.keys.sort.map {|key| key.ljust(ml," ") + ": " + hash[key].to_s }.join("\n")
  end

end
