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

class AddSwissmentorBaseMeta < ActiveRecord::Migration
  def self.up
    create_table  "swissmentor_base_metas" do |t|
      t.string  "process",             :limit => 10
      t.string  "client_user",         :limit => 20
      t.string  "client_ip",           :limit => 40
      t.string  "peer_ip",             :limit => 40
      t.integer "log_metas_id"
      t.integer "pure_metas_id"
    end
    add_index "swissmentor_base_metas","process"
    add_index "swissmentor_base_metas","client_user"
    add_index "swissmentor_base_metas","client_ip"
    add_index "swissmentor_base_metas","peer_ip"
    add_index "swissmentor_base_metas","log_metas_id"
    add_index "swissmentor_base_metas","pure_metas_id"

    create_table  "swissmentor_data_metas" do |t|
      t.string  "action",             :limit => 10
      t.integer "object_id"
      t.integer "parent_object_id"
      t.string  "object_type",       :limit => 20
      t.string  "object_name",       :limit => 40
      t.string  "access",            :limit => 20
      t.integer "swissmentor_base_metas_id"
    end
    add_index "swissmentor_data_metas","action"
    add_index "swissmentor_data_metas","object_id"
    add_index "swissmentor_data_metas","parent_object_id"
    add_index "swissmentor_data_metas","object_type"
    add_index "swissmentor_data_metas","object_name"
    add_index "swissmentor_data_metas","access"
    add_index "swissmentor_data_metas","swissmentor_base_metas_id"
  end
  
  def self.down
    drop_table "swissmentor_base_metas"
    drop_table "swissmentor_data_metas"
  end

end

