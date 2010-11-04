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

  # Condition Class for matching a operator agains any column in the datasource
  class AnyCondition < Condition
    attr_reader :operator, :value
    # Create a new any condition
    def initialize(operator, value, options = {})      
      @operator = operator
      @value = value
      @options = options
    end

    # This is only for display to user. Column field is not used because
    # it anyway should match any column.
    def column 
      "ANY"
    end
    
    # Sql statement
    def sql(options = {})
      options = normalize_options(options)
      return "ANY #{operator} #{value}" unless (table_class = options[:table_class])
      "( " + table_class.table.columns.map { |c|
	Condition.new(c.name, operator, value,@options)
      }.map { |c| c.sql(table_class) }.compact.join(' OR ') + " )"
    end

    # This condition is applyable to any source. (always true)
    def applyable(options = {})
      true
    end
    
  end

