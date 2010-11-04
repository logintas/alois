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

class CreateSquidMetas < ActiveRecord::Migration
  def self.up
      create_table :squid_metas do |t|
      t.integer :process_id
      t.integer :seconds_since_epoch
      t.integer :subsecond_time
      t.integer :response_time_milliseconds
      t.string :client_source_ip, :limit => 40
      t.string :request_status, :limit => 30
      t.integer :http_status_code
      t.integer :reply_size
      t.string :request_method, :limit => 10
      t.text :request_url
      t.string :user_name, :limit => 40
      t.string :hierarchy_status, :limit => 30
      t.string :client_fqdn, :limit => 50
      t.string :mime_type, :limit => 60      
      t.string :request_protocol, :limit => 10
      t.string :request_host, :limit => 50
      t.integer :pure_metas_id
      t.integer :log_metas_id

    end

    add_index :squid_metas, :pure_metas_id
    add_index :squid_metas, :log_metas_id
    add_index :squid_metas, :process_id
    add_index :squid_metas, :response_time_milliseconds
    add_index :squid_metas, :client_source_ip
    add_index :squid_metas, :request_status
    add_index :squid_metas, :http_status_code
    add_index :squid_metas, :reply_size
    add_index :squid_metas, :request_method
    add_index :squid_metas, :user_name
    add_index :squid_metas, :mime_type
    add_index :squid_metas, :hierarchy_status
    add_index :squid_metas, :client_fqdn
    add_index :squid_metas, :request_protocol
    add_index :squid_metas, :request_host
  end

  def self.down
    drop_table :squid_metas
  end
end
