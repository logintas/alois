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

  # Condition class
  class Condition

    # List of all supported Operators
    OPERATORS = [ "=", "!=", 
      "LIKE", "NOT LIKE",
      ">",">=",
      "<","<=",
      "IS NULL","IS NOT NULL",
      "SQL","DATE","IPRANGE","FILTER"] unless defined?(OPERATORS)


    # options can either be a table_class or a hash of options.
    def normalize_options(options = {})
      return options if options.class == Hash
      {:table_class => options}
    end

    # Return true if given options are valid
    def valid?(options = {})
      options = normalize_options(options)
      validate(options)
      return true
    rescue
      false
    end
    
    
    # raises an exception if the given options are not valid
    def validate(options = {})
      options = normalize_options(options)
      self.sql(options[:table_class])
      raise "No column defined." if column.nil? or column.strip == ""
      if options[:table_class]
	raise "Condition not appliable to #{options.inspect}." unless applyable(options)
      end
    end

    # Default is always true. Updatable means if the
    # condition can be updated with new properties from UI.
    def updatable?
      true
    end
    

    # Creates a appropriate condition class, sql-, date-, iprange-, any-, filter-condition
    def self.create(column, operator, value, options = {})
      case operator
      when "SQL"
	return SqlCondition.new(value, options)
      when "DATE"
	return DateCondition.new(column, operator , value)
      when "IPRANGE"
	return IpRangeCondition.new(column, operator , value)	
      when "FILTER"
	return FilterCondition.new(column, operator, value)
      else
	if column == "ANY" then
	  return AnyCondition.new(operator,value,options)
	else
	  return Condition.new(column, operator, value, options )
	end
      end
    end

    # Finds a column in the table_class. If there is no such column, nil will be returned.
    def find_column(name, options = {})
      options = normalize_options(options)
      return nil unless (table_class = options[:table_class])
      
      name =~ /(.*\.)?(.*)/
      return nil if 
	$1 != nil and 
	$1 != table_class.table.table_name
      
      for col in table_class.table.columns
	return col if col.name == $2 	
      end
      return nil
    end

    # Returns if there is a column with that name
    def has_column?(name,options = {})
      return !!find_column(name,options)
    end
    
    attr_reader :operator, :value
    # Initializes a new condition
    def initialize(column, operator, value, options = {})
      return super(column) if column.instance_of?(Hash)
      throw "No column given." unless column
      throw "No operator given." unless operator

      @column = column
      @operator = operator
      @value = value  
      if @value == nil
	@operator = "IS NULL" if @operator == "="
	@operator = "IS NOT NULL" if @operator == "!="
      end
      @value = nil if @operator == "IS NULL" || @operator == "IS NOT NULL"
      @options = options
      #    value = @conditions[i][2]
      #    value = [value] if value.class.name == "String"
      #    value = [] if value == nil
      #    ret = ""
      #    for val in value 
      #      ret += " OR " if ret != ""
      #      ret += "#{@conditions[i][0]} #{@conditions[i][1]} #{val}"
      #    end
      #    return "(#{ret})"
    end
    
    # returns the column string for use in SQL (including tablename if information available)
    def column(options = {})
      options = normalize_options(options)      
      return "" if @column == ""
      @column =~ /(.*\.)?(.*)/
      if (table_class = options[:table_class])
	"#{table_class.table.table_name}.`#{$2}`"
      else
	"#{$1}`#{$2}`"
      end
    end
    
    # returns the quoted value to use in SQL
    def quoted_value(options = {}) 
      options = normalize_options(options)
      col = find_column(@column,options)
      return ActiveRecord::Base.quote_value(value) unless col 
      return ActiveRecord::Base.quote_value(col.type_cast(value)) if col.number?
      return ActiveRecord::Base.quote_value(value)
    end

    # Returns the condition to use in SQL
    def sql(options = {})
      options = normalize_options(options)
      if value	
	"#{column(options)} #{operator} #{quoted_value(options)}"
      else
	"#{column(options)} #{operator}"
      end
    end
    
    # Returns weather the condition is appliable.
    def applyable(options = {})
      options = normalize_options(options)
      return true if options[:table_class].nil?
      return has_column?(@column,options)
    end

    # Update the condition from ui params
    def update_from_params(params)
      @value = params[:value] if params
    end

    # TODO: probably this is deprecated
    def descriptions
#      ["Column name or name of the rule.","Column/Name",
#        nil,nil,nil,conditions[i][0],nil],
#	["Operator for the rule.","Operator",
#        nil,nil,nil,conditions[i][1],nil],
#	["Value to compare for the rule.","Value",
#        nil,nil,nil,value,nil],
#	["Percentage of items matched this rule.","%",
#        get_condition(i), nil, "ALL", nil, "del_condition","d"],
#	["All values matched by that rule, and are in this sample.","In %",
#        get_condition_string(true), nil, get_condition(i), nil,nil,nil],
#	["All values matched by that rule, that are not in this sample.","Not In %",
#        get_condition(i), get_condition_string(true) , get_condition(i), nil,'negate_all_but','>'],
#	["How many records more would be in the sample if this rule where deleted.","Banish",
#        get_condition_string(true,i),get_condition_string(true), nil, nil,'banished', '>'],
#	["Disable/Enable the rule.","",
#        nil, nil, nil, if conditions[i][3] then "on" else "off" end, 'toggle', '>']
      
    end
  end
