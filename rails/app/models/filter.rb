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

  # TODO: document difference between appliable and valid
  class Filter < ActiveRecord::Base
    validates_presence_of :name
    validates_uniqueness_of :name

    attr_accessor :datasource

    # Validates weather all conditions are valid for source
    validate do |f|
      i = 0
      errors = f.conditions.map {|c|
	i+=1
	begin
	  if f.datasource
	    c.validate(f.datasource.table)
	  else
	    c.validate
	  end
	  nil
	rescue
	  "\##{i}: #{$!}"
	end
      }.compact
      f.errors.add('yaml_declaration',errors.join(", ")) if errors.length > 0
    end

    # Parses text and returns a list of filters
    def self.parse_text_field(text)
      return [] if text.nil? or text.strip == ""
      return text.split(",").map {|filter_id| 
	raise "Filterid '#{filter_id}' is invalid." unless filter_id.strip =~ /^\d+$/
	Filter.find(filter_id.strip)
      }      
    end

    # Create new Filter based on UI parameters
    def self.create_from_params(params)
      if params[:filter_id] then
        f = find(params[:filter_id])
        throw "Filter with id '#{params[:filter_id]}' not found!" if f == nil
      end
      if params[:filter_name] then
        f = find_by_name(params[:filter_name])
        throw "Filter with name '#{params[:filter_name]}' not found!" if f == nil
      end
      if f == nil then
        Filter.table_name = 'filters'
        f = Filter.new
	throw params[:conditions]
        f.yaml_declaration = params[:conditions]
      end
      return f if f
      throw "Could not create filter of parameters."
    end

    # Returns all conditions stored in the yaml_declaration field
    def conditions
      c = [DateCondition,SqlCondition,AnyCondition,IpRangeCondition,FilterCondition]
      return [] unless self.yaml_declaration
      y = YAML.parse(self.yaml_declaration)
      return [] unless y
      y.transform 
    end

    # Set new condition array
    def conditions=(c)
      throw c unless c.class == Array
      self.yaml_declaration = c.to_yaml
    end

    # Returns a array of SQL conditions for that filter
    def sql(options = {})      
      table = options[:table_class]	
      if table.respond_to?(:do_not_use_view_for_query) and table.do_not_use_view_for_query
	conditions.map {|c| c.sql(options) }
      else
	conditions.map {|c| c.sql(options[:table_class]) }
      end
    end

    # Returns if all condtions can be applied to the table
    def valid_for_table?(table)
      conditions.reject {|c| c.valid?(table)}.length == 0
    end

    # Returns the SQL conditions for that filter, this can be used in where clause of a query.
    def get_condition_string(table, real = false, withoutrule = -1,options = {})      
      ret = conditions.select{|c| c.valid?(table) }.map {|c| c.sql(table) }
      ret[withoutrule] = nil if withoutrule != -1
#      if not options[:without_date]
#	dc = DateCondition.new("date", from_date, to_date, time_description)
#	ret << [dc.sql]	  
#      end
      ret = ret.compact
      ret = ret.join(" AND ")
      return nil if ret == ""
      return ret
      
#      if not real then
#	if options[:negative_set] then
#	  ret = "1=1" if ret == nil
#	  ret = "NOT (#{ret})"
#	end
#	if options[:global_rule_number] then
#	  if options[:banished_set] then
#	    c = get_condition_string(true,options[:global_rule_number])
#	    c = "1=1" if c == nil
#	    ret += " AND #{c}"
#	  else
#	    ret += " AND #{get_condition(options[:global_rule_number])}"
#	  end
#	end
#      end      
    end   
    
    # Return true if all conditions are appliable
    def applyable(table_class)
      for condition in conditions
	return false unless condition.applyable(table_class)
      end
      return true
    end
  end
