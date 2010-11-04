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

class CreateCiscoSessionTable < ActiveRecord::Migration

  def self.up
 ActiveRecord::Base.transaction do
    create_table :cisco_session_metas do |t|
      t.column :msg, :string, :limit => 100
      t.column :session_type, :string, :limit => 30
      t.column :duration, :time
      t.column :in_bytes, :integer
      t.column :out_bytes, :integer      
      t.column :cisco_metas_id, :integer
    end
    add_index :cisco_session_metas, :msg
    add_index :cisco_session_metas, :session_type       
    add_index :cisco_session_metas, :cisco_metas_id    
    end
  end

  def self.down
    drop_table :cisco_session_metas
  end
end
