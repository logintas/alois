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

class CreateAlarms < ActiveRecord::Migration
  def self.up
    create_table :alarms do |t|
      t.column :created_at, :datetime
      t.column :sentinel_id, :integer
      t.column :comment, :string
      t.column :acknowledge, :boolean
      t.column :updated_at, :datetime
      t.column :updated_by, :string
      t.column :data, :binary
      t.column :log, :binary
    end
  end

  def self.down
    drop_table :alarms
  end
end
