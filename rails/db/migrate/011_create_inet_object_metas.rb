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

class CreateInetObjectMetas < ActiveRecord::Migration
  def self.up
    create_table :inet_object_metas do |t|
      t.column "objecttype", :string, :limit => 30
      t.column "object_id", :string, :limit => 512
      t.column "version", :string, :limit => 30
      t.column "filename", :string, :limit => 256
      t.column "description", :string, :limit => 256
      t.column "object_hashes", :string, :limit => 256
      t.column "object_url", :string, :limit => 512      
      t.column "inet_header_metas_id", :integer
      t.column "inet_object_metas_id", :integer
    end
    add_index "inet_object_metas", ["objecttype"]
    add_index "inet_object_metas", ["object_id"]
    add_index "inet_object_metas", ["version"]
    add_index "inet_object_metas", ["filename"]
    add_index "inet_object_metas", ["object_hashes"]
    add_index "inet_object_metas", ["object_url"]
    add_index "inet_object_metas", ["inet_header_metas_id"]
    add_index "inet_object_metas", ["inet_object_metas_id"]
  end

  def self.down
    drop_table :inet_object_metas
  end
end
