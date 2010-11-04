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

class AddProcessStatusToAlarm < ActiveRecord::Migration
  def self.up
    add_column :alarms, :process_state, :integer
    add_column :alarms, :responsible_person, :string
    add_index :alarms, :process_state, :default => 0, :null => false
    add_index :alarms, :responsible_person

    execute("UPDATE alarms SET process_state = 0 WHERE acknowledge = 0 or acknowledge IS NULL")
    execute("UPDATE alarms SET process_state = 10 WHERE acknowledge = 1")
    remove_column :alarms, :acknowledge
  end

  def self.down
    raise "There are other states than 0 and 10, cannot downgrade" if
      Alarm.find(:first, :conditions => "process_state != 0 and process_state != 10")
    
    add_column :alarms, :acknowledge, :boolean
    execute("UPDATE alarms SET acknowledge = 0 WHERE process_state = 0")
    execute("UPDATE alarms SET acknowledge = 1 WHERE process_state = 10")        

    remove_column :alarms, :process_state
    remove_column :alarms, :responsible_person
  end
end
