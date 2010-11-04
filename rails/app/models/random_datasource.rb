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

class RandomDatasource
  RANDOM_TABLE_NAME = "RANDOM_TABLE"

  class MyColumn
    attr_accessor :name

    def initialize(name)
      @name = name
    end
        
  end

  attr_accessor :columns

  def initialize(columns)
    @columns = columns.map{|n| MyColumn.new(n)}
  end

  def name
    RANDOM_TABLE_NAME
  end
  def table_name
    RANDOM_TABLE_NAME
  end

  def length
    100
  end

  def data
    rows = []
    100.times {
      col = {}
      columns.map{|c| c.name}.each {|name|
	col[name] = rand(10)
      }
      rows.push(col)
    }
    rows
  end

  def table
    self
  end
  
end
