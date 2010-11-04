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

class AddTableAcePasscodeMetas< ActiveRecord::Migration
  def self.up
    return if AcePasscodeMeta.table_exists?

    create_table "ace_passcode_metas" do |t|
      t.column "action", :string, :limit => 40
      t.column "login", :string, :limit => 30
      t.column "user_name", :string, :limit => 100
      t.column "token", :string, :limit => 15
      t.column "group_name", :string, :limit => 100
      t.column "site", :string, :limit => 100
      t.column "agent_host", :string, :limit => 100
      t.column "server", :string, :limit => 100
      
      t.column "windows_event_metas_id", :integer
      t.column "log_metas_id", :integer
    end
    
    add_index "ace_passcode_metas", ["action"], :name => "ace_passcode_metas_action_index"
    add_index "ace_passcode_metas", ["login"], :name => "ace_passcode_metas_login_index"
    add_index "ace_passcode_metas", ["user_name"], :name => "ace_passcode_metas_user_name_index"
    add_index "ace_passcode_metas", ["group_name"], :name => "ace_passcode_metas_group_index"
    add_index "ace_passcode_metas", ["site"], :name => "ace_passcode_metas_site_index"
    add_index "ace_passcode_metas", ["agent_host"], :name => "ace_passcode_metas_agent_host_index"
    add_index "ace_passcode_metas", ["server"], :name => "ace_passcode_metas_server_index"

    add_index "ace_passcode_metas", ["windows_event_metas_id"], :name => "ace_passcode_metas_windows_event_metas_id_index"
    add_index "ace_passcode_metas", ["log_metas_id"], :name => "ace_passcode_metas_log_metas_id_index"
  end

  def self.down
    drop_table "ace_passcode_metas"
  end

end
