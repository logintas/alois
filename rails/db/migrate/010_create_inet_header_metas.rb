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

class CreateInetHeaderMetas < ActiveRecord::Migration
  def self.up
    create_table :inet_header_metas do |t|
      t.column "date", :date
      t.column "time", :time
      t.column "milliseconds", :integer
      t.column "severity", :string, :limit => 10
      t.column "system_id", :string, :limit => 30
      t.column "msg_id", :string, :limit => 30
      t.column "user_id", :string, :limit => 30
      t.column "eventtype", :string, :limit => 30
      t.column "pure_metas_id", :integer
      t.column "log_metas_id", :integer
      t.column "client_ip", :string, :limit => 32
      t.column "server_ip", :string, :limit => 32
      t.column "session_id", :string,  :limit => 32
      t.column "hit_number", :integer
      t.column "num_object_hits", :integer
      t.column "text1", :string, :limit => 1024
      t.column "text2", :string, :limit => 1024
    end

    add_index "inet_header_metas", ["date"]
    add_index "inet_header_metas", ["severity"]
    add_index "inet_header_metas", ["system_id"]
    add_index "inet_header_metas", ["msg_id"]
    add_index "inet_header_metas", ["user_id"]
    add_index "inet_header_metas", ["eventtype"]
    add_index "inet_header_metas", ["pure_metas_id"]
    add_index "inet_header_metas", ["log_metas_id"]
    add_index "inet_header_metas", ["client_ip"]
    add_index "inet_header_metas", ["server_ip"]
    add_index "inet_header_metas", ["session_id"]
    add_index "inet_header_metas", ["hit_number"]
    add_index "inet_header_metas", ["num_object_hits"]
  end

  def self.down
    drop_table :inet_header_metas
  end
end
