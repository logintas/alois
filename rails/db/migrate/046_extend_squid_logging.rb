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

class ExtendSquidLogging < ActiveRecord::Migration
  def self.up
    rename_column :squid_metas, :client_fqdn, :server_ip
    
    add_column :squid_metas, :protocol_version, :string, :limit => 5
    add_column :squid_metas, :client_fqdn, :string, :limit => 50
    add_column :squid_metas, :referer, :text
    
    add_index :squid_metas, :protocol_version
    # because client_fqdn was renamed, index exist.
    add_index :squid_metas, :client_fqdn, :name => "new_client_fqdn_index"
    
    add_column :squid_metas, :user_indent, :string, :limit => 40
    add_column :squid_metas, :user_agent, :string, :limit => 40
    add_column :squid_metas, :user_auth, :string, :limit => 40
    add_column :squid_metas, :user_acl, :string, :limit => 40
    add_column :squid_metas, :acl_log, :text
    
    add_index :squid_metas, :user_indent
    add_index :squid_metas, :user_agent
    add_index :squid_metas, :user_auth
    add_index :squid_metas, :user_acl    
    
    create_table :squid_request_header_metas do |t|
      t.column :authorization, :string, :limit => 50
      t.column :cache_control, :string, :limit => 50
      t.column :from, :string, :limit => 50
      t.column :host, :string, :limit => 50
      t.column :if_modified_since, :string, :limit => 50
      t.column :if_unmodified_since, :string, :limit => 50
      t.column :pragma, :string, :limit => 50
      t.column :proxy_authorization, :string, :limit => 50
      t.column :squid_metas_id, :integer
    end
    
    add_index :squid_request_header_metas, :authorization
    add_index :squid_request_header_metas, :from
    add_index :squid_request_header_metas, :host    
    add_index :squid_request_header_metas, :squid_metas_id
    
    create_table :squid_response_header_metas do |t|
      t.column :server, :string, :limit => 50
      t.column :content_md5, :string, :limit => 50
      t.column :age, :string, :limit => 50
      t.column :cache_control, :string, :limit => 50
      t.column :content_encoding, :string, :limit => 50
      t.column :content_language, :string, :limit => 50
      t.column :date, :date
      t.column :last_modified, :datetime
      t.column :location, :string, :limit => 50
      t.column :pragma, :string, :limit => 50
      t.column :proxy_authenticate, :string, :limit => 50
      t.column :via, :string, :limit => 50
      t.column :www_authenticate, :string, :limit => 50
      t.column :squid_metas_id, :integer
    end

    add_index :squid_response_header_metas, :server
    add_index :squid_response_header_metas, :age
    add_index :squid_response_header_metas, :content_encoding
    add_index :squid_response_header_metas, :content_language
    add_index :squid_response_header_metas, :date
    add_index :squid_response_header_metas, :squid_metas_id
  end

  def self.down
    drop_table :squid_response_header_metas
    drop_table :squid_request_header_metas


    remove_column :squid_metas, :protocol_version
    remove_column :squid_metas, :client_fqdn
    remove_column :squid_metas, :referer

    remove_column :squid_metas, :user_indent
    remove_column :squid_metas, :user_agent
    remove_column :squid_metas, :user_auth
    remove_column :squid_metas, :user_acl
    remove_column :squid_metas, :acl_log

    rename_column :squid_metas, :server_ip, :client_fqdn
  end
end
