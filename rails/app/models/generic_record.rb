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

  # This record is used to acces tables and views without models.
  # TODO: Probably we will get troubels if two tables use this class simultaneously, or two users use alois at the same time. We could on demand create new classes for each table.
  class GenericRecord < ActiveRecord::Base

    # Returns a class for accessing the table with tablename.
    def self.get_class_from_tablename(tablename)
      return nil unless tablename
      GenericRecord.table_name = tablename
      self
    end

    # Returns a sql query for view creation out of UI.
    def join_query(query = nil)      
      query = "#{self.class.table_name}" unless query     
      p = parent
      if p then
	query = "#{query} LEFT JOIN #{p.class.table_name} ON #{self.class.table_name}.id = #{p.class.table_name}.id"
	query = parent.join_query(query)
      end
      return query
    end  

    # returns the view if the table has a view and the field do_not_use_view_for_query is true
    def self.get_view_if_it_does_not_use_mysql_view
      view = View.get_class_from_tablename(self.table_name)
      return nil if view.nil?
      return nil unless view.do_not_use_view_for_query
      view
    end

    # TODO: Document this after view class is documented
    def self.override_query(options)
      if view = get_view_if_it_does_not_use_mysql_view
	View.update_query(view.sql,options)
      end      
    end

    # Returns the last executed find query of generic record. Just for debugging purpose
    def self.last_executed_find
      @last_sql
    end

    # Activerecord like finder function, with special behaviour for views
    def self.find(*args)
      if args.first == :all and (@last_sql = self.override_query(args[1]))
	return find_by_sql(@last_sql)
      end
      
      if [:first, :last, :all].include?(args.first)
	return super
      end

      id_f = "id"
      if (view = get_view_if_it_does_not_use_mysql_view)
	id_f = "#{view.id_source_table}.id" 
      end

      if @last_sql = self.override_query(:conditions => "#{id_f} = #{args[0].to_i}")
	find_by_sql(@last_sql)[0]
      else
	super
      end
    end

    # Activerecord like count function, with special behaviour for views
    def self.count(*args)
      if m_query = self.override_query(args[0])
	self.connection.select_value("SELECT COUNT(*) FROM (#{m_query}) AS m_query").to_i
      else
	super
      end
    end

  end

