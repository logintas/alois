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

class UpdateChartTable < ActiveRecord::Migration
  def self.up
    add_column :charts, :column3, :string
    add_column :charts, :max_values, :integer, :default => 45
    add_column :charts, :stacked, :boolean, :default => false

#    rename_column :charts, :aggregation_column, :aggregation
#    Chart.find(:all).each {|chart|
#      if (chart.aggregation_function or "").strip != ""
#	chart.aggregation = "#{chart.aggregation_function}(#{chart.aggregation})"
#	chart.save_without_validation
#      end
#    }
#    remove_column :charts, :aggregation_function
  end

  def self.down
    remove_column :charts, :column3
    remove_column :charts, :max_values
    remove_column :charts, :stacked

#    add_column :charts, :aggregation_function, :string
#    Chart.find(:all).each {|chart|
#      if (chart.aggregation =~ /^\s*([^\)]+)\s*\(\s*([^\)]+)\s*\)$/)	
#	chart.aggregation = $2
#	chart.aggregation_function = $1
#	chart.save_without_validation
#      end
#    }
#    rename_column :charts, :aggregation, :aggregation_column
  end
end
