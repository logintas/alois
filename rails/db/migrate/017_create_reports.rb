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

class CreateReports < ActiveRecord::Migration
  def self.up
    create_table :reports do |t|
      t.column :name, :string
      t.column :date, :date
      t.column :time, :time
      t.column :path, :string
      t.column :report_template_id, :integer
      t.column :sentinel_id, :integer
      t.column :generated_by, :string
    end

    add_index "reports", ["date"]
    add_index "reports", ["name"]
    add_index "reports", ["report_template_id"]
    add_index "reports", ["sentinel_id"]
    add_index "reports", ["generated_by"]
  end

  def self.down
    drop_table :reports
  end
end
