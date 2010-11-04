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

class AddTableWindowsEventMetas < ActiveRecord::Migration
  def self.up
    return if WindowsEventMeta.table_exists?
    create_table "windows_event_metas" do |t|
      t.column "log_name", :string, :limit => 30
      t.column "field1", :integer
      t.column "event_type", :string, :limit => 20
      t.column "field3", :integer
      t.column "date", :date
      t.column "time", :time
      t.column "event_id", :integer
      t.column "source", :string, :limit => 30
      t.column "user", :string
      t.column "category", :string, :limit => 30
      t.column "level", :string, :limit => 30
      t.column "computer", :string
      t.column "facility", :string, :limit => 30
      t.column "data", :binary
      t.column "field14", :integer
      
      t.column "pure_metas_id", :integer
      t.column "log_metas_id", :integer
    end
    
    add_index "windows_event_metas", ["log_name"], :name => "windows_event_metas_log_name_index"
    add_index "windows_event_metas", ["event_type"], :name => "windows_event_metas_event_type_index"
    add_index "windows_event_metas", ["date"], :name => "windows_event_metas_date_index"
    add_index "windows_event_metas", ["user"], :name => "windows_event_metas_user_index"
    add_index "windows_event_metas", ["source"], :name => "windows_event_metas_source_index"
    add_index "windows_event_metas", ["category"], :name => "windows_event_metas_category_index"
    add_index "windows_event_metas", ["level"], :name => "windows_event_metas_message_level_index"
    add_index "windows_event_metas", ["computer"], :name => "windows_event_metas_computer_index"
    add_index "windows_event_metas", ["facility"], :name => "windows_event_metas_facility_index"

    add_index "windows_event_metas", ["pure_metas_id"], :name => "windows_event_metas_pure_metas_id_index"
    add_index "windows_event_metas", ["log_metas_id"], :name => "windows_event_metas_log_metasid_index"
  end

  def self.down
    drop_table "windows_event_metas"
  end

end
