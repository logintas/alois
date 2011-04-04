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

  class View < ActiveRecord::Base
    has_many :sentinels

    validate do |view|
      if view.do_not_use_view_for_query
	view.example_replacement_query
      end
    end

    def example_replacement_query
	# try to replace the values
	View.update_query(self.sql,
			  {:conditions => "date = CURRENT_DATE and id LIKE '1%'",
			    :order => "id",
			    :limit => "13",
			    :offset => "9"})			   
    end
    
    def host
      view_connection.host
    end

    def display_name
      self.name
    end

    def self.get_class_from_tablename(tablename)
      return nil unless tablename
      if tablename =~ /^view_(\d*)$/
	return find($1)
      end
      return nil
    end

    def source_table_class
      return @source_table_class if @source_table_class
      @source_table_class = Prisma::Database.get_class_from_tablename(id_source_table) if defined?(Prisma::Database)
      @source_table_class = View.get_class_from_tablename(id_source_table) unless @source_table_class
      @source_table_class = GenericRecord.get_class_from_tablename(id_source_table) unless @source_table_class
      return @source_table_class
    end
      
    # Override Base functions
    def save
      create_view
      ret = super
      create_view
      ret
    end
        
    def table  
      return @table if @table
      GenericRecord.table_name = view_name
      GenericRecord.reset_column_information()
      ActiveRecord::Base.connection_handler.connection_pools["GenericRecord"] = view_connection.pool
        
      begin
      create_view unless GenericRecord.table_exists?
      rescue
        $log.error("Error creating view: #{$!}")
      end
      @table = GenericRecord
      return @table
    end

    def self.get_join
      return nil
    end

    def destroy
      View.drop_view(view_connection, view_name)
      super
    end

    def view_name
      "view_#{id}"
    end

    def table_name
      view_name
    end

    def sql
      s = self.sql_declaration
      s.gsub!(/<<VIEW\(([^\)]*)\)>>/) {|match|
	view = View.find_by_name($1)
	throw "View with name '#{$1}' not found!" unless view
	view.table_name
      }
      s
    end

    # Create a new view in the default (normally alois) database.
    def View.create_view(connection, name, query, throw_exception = false)
      begin
        View.drop_view(connection, name)
        throw "No query given." unless query
        throw "No name given." unless name
        create = "CREATE VIEW #{name} AS " + query
        $log.debug{create}
          connection.activerecord_connection.execute(create)
      rescue ActiveRecord::Transactions::TransactionError
        raise $!
      rescue
        $log.warn "Could not create view #{name}: #{$!.to_s}" if $log.warn?
        throw $! if throw_exception
      end
    end
    
    # Drop the view with the given name in the default (normally alois) database..
    def View.drop_view(connection, name)
      drop = "DROP VIEW IF EXISTS #{name}"
      $log.debug{drop}
      connection.activerecord_connection.execute(drop)
    end

    def view_connection
      # TODO: implement function to find correct parent class
      if !id_source_table.blank? and !(id_source_table =~ /^view_/)
        klass = eval(id_source_table.classify)
      else
        klass = LogMeta
      end
      
      conn = Connection.from_pool(klass.connection_pool)
      raise "Connection for class #{klass.name} not found" unless conn
      conn
    end

    def create_view              
      # not working because show field does not
      # work anymore. Always create view
      # Prisma.drop_view(view_name)
#      if self.do_not_use_view_for_query
#	Prisma.create_view(view_name, sql_declaration,true)
#      else
      View.create_view(view_connection, view_name, sql,true)
#      end
    end
    
    def get_date_column
      date_column_name or "date"
    end

    def get_select
      return "*"
    end

    def get_join
      return nil
    end
        
    #-------------------- quering ---------
    #   SELECT
    #    [ALL | DISTINCT | DISTINCTROW ]
    #      [HIGH_PRIORITY]
    #      [STRAIGHT_JOIN]
    #      [SQL_SMALL_RESULT] [SQL_BIG_RESULT] [SQL_BUFFER_RESULT]
    #      [SQL_CACHE | SQL_NO_CACHE] [SQL_CALC_FOUND_ROWS]
    #    select_expr, ...
    #    [FROM table_references
    #    [WHERE where_condition]
    #    [GROUP BY {col_name | expr | position}
    #      [ASC | DESC], ... [WITH ROLLUP]]
    #    [HAVING where_condition]
    #    [ORDER BY {col_name | expr | position}
    #      [ASC | DESC], ...]
    #    [LIMIT {[offset,] row_count | row_count OFFSET offset}]
    #    [PROCEDURE procedure_name(argument_list)]
    #    [INTO OUTFILE 'file_name' export_options
    #      | INTO DUMPFILE 'file_name'
    #      | INTO var_name [, var_name]]
    #    [FOR UPDATE | LOCK IN SHARE MODE]]

    def View.insert_generic(type, query, value, regexps)
      return query if value == "" or value.nil?

      regex = regexps.select {|reg| query =~ reg}[0]
      if regex
	query =~ regex
	case type
	when :before
	  throw "Missing ( ) in regexp #{regex}." unless $1
	  query.sub(regex, "#{value} #{$1}")
	when :after
	  throw "Missing ( ) in regexp #{regex}." unless $1
	  query.sub(regex, "#{$1} #{value}")
	when :substitute, :replace
	  query.sub(regex, "#{value}")
	end
      end
    end      

    def View.insert_condition(query, condition)
      return query if condition == "" or condition.nil?

      insert_generic(:after, query, "#{condition} AND", [/(WHERE)/i]) or
	insert_generic(:before, query, "WHERE #{condition}", [/(GROUP BY)/i,/(HAVING)/i, /(ORDER BY)/i, /(LIMIT)/i]) or
	query + " WHERE #{condition}"
    end

    def View.insert_limit_offset(query, limit, offset = nil)
      if offset
	val = "LIMIT #{offset.to_i}, #{limit.to_i}"
      else
	val = "LIMIT #{limit.to_i}"
      end
      insert_generic(:replace, query, val, [/LIMIT\s*\d+,\s*\d+/i,/LIMIT\s*\d+\s*OFFSET\s*\d+/i,/LIMIT\s*\d+/]) or
	insert_generic(:before, query, val, [/(PROCEDURE)/i,/(INTO\s)/i,/(FOR UPDATE)/i, /(LOCK IN)/i]) or
	query + " " + val
    end

    def View.insert_group(query, group_by)
      # we cannot simply replace a group by because a grouping on a grouping is not the same
      # as the second grouping alone.
      raise "There exist already a group by in the query, cannot insert group by: #{query.inspect}" if query =~ /GROUP\s+BY/
      val = "GROUP BY #{group_by}"
      insert_generic(:before, query, val, [/HAVING/i,/(ORDER BY)/i,/(LIMIT)/i,/(PROCEDURE)/i,/(INTO\s)/i,/(FOR UPDATE)/i, /(LOCK IN)/i]) or
	query + " " + val      
    end

    def View.insert_order(query, order)
      val = "ORDER BY #{order}"
      insert_generic(:replace, query, "#{val} LIMIT", [/ORDER\s*BY\s.*\s*LIMIT/i]) or
	insert_generic(:replace, query, "#{val} PROCEDURE", [/ORDER\s*BY\s.*\s*PROCEDURE/i]) or
	insert_generic(:replace, query, "#{val} INTO", [/ORDER\s*BY\s.*\s*INTO/i]) or
	insert_generic(:replace, query, "#{val} FOR UPDATE", [/ORDER\s*BY\s.*\s*FOR UPDATE/i]) or
	insert_generic(:replace, query, "#{val} LOCK IN", [/ORDER\s*BY\s.*\s*LOCK IN/i]) or
	insert_generic(:replace, query, "#{val}", [/ORDER\s*BY\s.*$/i]) or
	insert_generic(:before, query, val, [/(LIMIT)/i,/(PROCEDURE)/i,/(INTO\s)/i,/(FOR UPDATE)/i, /(LOCK IN)/i]) or
	query + " " + val      
    end
    
    def View.update_query(query, options = {})
      return query if options.nil? or options.length == 0
      # SELECT ...
      # UNION [ALL | DISTINCT] SELECT ...
      # [UNION [ALL | DISTINCT] SELECT ...]      
      parts = query.split(/union/i)
      new_query = parts.map! {|part|
	part = part.strip
	# remove leading ALL or DISTINCT
	start = ""
	part.sub!(/^(all)\s/i) {|v| start = $1; "" }
	part.sub!(/^(distinct)\s/i) {|v| start = $1; "" }
	if start == ""
	  start += "("
	else
	  start += " ("
	end

	# remove leading and tailing brackets
	while part.strip.starts_with?("(")
	  throw "'#{part}' starts with a ( but does not end with one." unless 
	    part.strip.ends_with?(")")
	  part = part.strip[1..-2]
	end

	part = View.insert_condition(part,options[:conditions]) if options[:conditions]	
	part = View.insert_limit_offset(part,options[:limit],options[:offset]) if options[:limit]
        if options[:group]
          raise "Cannot insert group by for union query: #{query.inspect}" if parts.length > 1
          part = View.insert_group(part,options[:group])
        end
	part = View.insert_order(part,options[:order]) if options[:order]
	part += " " unless part.ends_with?(" ")
	start + part
      }.join(") UNION ") + ")"
    end
    
  end
