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

  # The value field of SqlCondition will directly be inserted in the where clause of sql
  class SqlCondition < Condition

    def validate(table_class=nil)
      self.sql(table_class)
      if table_class
	raise "Condition not appliable to #{table_class}." unless applyable(table_class)
      end
    end

    def initialize(query, options = {})
      @value = query
    end

    # Always empty, column must be included in value
    def column
      ""
    end
    
    # Always "SQL", operator must be included in value
    def operator
      "SQL"
    end
        
    # Sql statement, value with brackets, so ORs can be included.
    # TODO: here pure SQL is included, maybe we should do some security checks
    def sql(options = {})
      "( #{@value} )"
    end

    def applyable(table_class)
      return true
    end
  end
