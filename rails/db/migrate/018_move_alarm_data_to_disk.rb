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

class MoveAlarmDataToDisk < ActiveRecord::Migration
  def self.up
    begin
      Alarm.connection.add_column "alarms", "path", :string
      
      Alarm.find(:all).each {|alarm|
	alarm.save_data(alarm["data"])
      }
      Alarm.connection.remove_column "alarms", "data"
    rescue
      Alarm.connection.remove_column "alarms", "path"
      raise $!
    end
  end

  def self.down
    begin
      Alarm.connection.add_column "alarms", "data", :binary
      
      Alarm.find(:all).each {|alarm|
	alarm["data"] = alarm.text
	alarm.save
	Pathname.new(alarm.path).rmtree	
      }
      Alarm.connection.remove_column "alarms", "path"
    rescue
      Alarm.connection.remove_column "alarms", "data"
      raise $!
    end
  end
end
