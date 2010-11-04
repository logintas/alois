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

class AddChartColumns < ActiveRecord::Migration
  def self.up
    c = Chart.connection
    c.add_column "charts", "height", :integer
    c.add_column "charts", "width", :integer    
  end

  def self.down
    c = Chart.connection
    c.delete_column "charts", "height"
    c.delete_column "charts", "width"
  end
end
