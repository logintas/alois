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

class CreateIpRanges < ActiveRecord::Migration
  def self.up
    create_table :ip_ranges do |t|
      t.string :name
      t.text :description
      t.string :from_ip
      t.string :to_ip
      t.string :netmask
      t.boolean :enabled, :default => true
    end

    create_table :ip_ranges_mappings do |t|
      t.integer :ip_range1_id
      t.integer :ip_range2_id
      t.text :description
    end
  end

  def self.down
    drop_table :ip_ranges
    drop_table :ip_ranges_mappings
  end
end
