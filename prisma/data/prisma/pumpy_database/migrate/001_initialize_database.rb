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

class InitializeDatabase < ActiveRecord::Migration
  def self.up
    
    create_table "file_raws" do |t|
      t.column "dirname", :string
      t.column "basename", :string
      t.column "ftype", :string, :limit => 20
      t.column "size", :integer
      t.column "mtime", :datetime
      t.column "atime", :datetime
      t.column "ctime", :datetime
      t.column "umask", :integer
      t.column "uid", :integer
      t.column "gid", :integer
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
      t.column "options", :string
      t.column "msg", :binary
    end

    create_table "syslogd_raws" do |t|
      t.column "ip", :string, :limit => 40
      t.column "host", :string
      t.column "facility", :string, :limit => 10
      t.column "priority", :string, :limit => 10
      t.column "level", :string, :limit => 10
      t.column "tag", :string, :limit => 10
      t.column "date", :date
      t.column "time", :time
      t.column "program", :integer, :limit => 15
      t.column "created_at", :datetime
      t.column "msg", :string
    end

    create_table "raws_states" do |t|
      t.column "table_name", :string, :limit => 20
      t.column "count_limit", :integer
      t.column "count_time", :float
      t.column "count_value", :integer
      t.column "delete_time", :float
      t.column "delete_value", :integer
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
    end

    add_index "raws_states", ["table_name"], :name => "raws_states_table_name_index"
  end

  def self.down
    raise IrreversibleMigration
  end
  
end
