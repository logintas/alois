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

# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 4) do

  create_table "file_raws", :force => true do |t|
    t.string   "dirname"
    t.string   "basename"
    t.string   "ftype",      :limit => 20
    t.integer  "size"
    t.datetime "mtime"
    t.datetime "atime"
    t.datetime "ctime"
    t.integer  "umask"
    t.integer  "uid"
    t.integer  "gid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "options"
    t.binary   "msg"
  end

  create_table "raws_states", :force => true do |t|
    t.string   "table_name",   :limit => 20
    t.integer  "count_limit"
    t.float    "count_time"
    t.integer  "count_value"
    t.float    "delete_time"
    t.integer  "delete_value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "raws_states", ["table_name"], :name => "raws_states_table_name_index"

  create_table "syslogd_raws", :force => true do |t|
    t.string   "ip",         :limit => 40
    t.string   "host"
    t.string   "facility",   :limit => 10
    t.string   "priority",   :limit => 10
    t.string   "level",      :limit => 10
    t.string   "tag",        :limit => 10
    t.date     "date"
    t.time     "time"
    t.integer  "program",    :limit => 15
    t.datetime "created_at"
    t.binary   "msg",        :limit => 255
  end

end
