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

class AddActionToSentinel < ActiveRecord::Migration
  def self.up
    add_column "sentinels","action",:integer
    add_index "sentinels","action"

    enabled = Sentinel::ACTIONS.invert[:alarm_and_report]
    disabled = Sentinel::ACTIONS.invert[:disabled]
    Sentinel.find(:all).each {|s|
      s.action = (if s.enabled then enabled else disabled end)
      s.save_without_validation
    }
    
    remove_column "sentinels", "enabled"
  end

  def self.down
    add_column "sentinels", "enabled", :boolean

    disabled = Sentinel::ACTIONS.invert[:disabled]
    Sentinel.find(:all).each {|s|
      s.enabled =  (s.action != disabled)
      s.save_without_validation
    }
    
    remove_column "sentinels","action"
  end
end
