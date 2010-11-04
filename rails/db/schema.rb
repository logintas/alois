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

ActiveRecord::Schema.define(:version => 20101020125711) do

  create_table "alarms", :force => true do |t|
    t.datetime "created_at"
    t.integer  "sentinel_id"
    t.string   "comment"
    t.datetime "updated_at"
    t.string   "updated_by"
    t.binary   "log"
    t.string   "path"
    t.integer  "alarm_level"
    t.integer  "process_state"
    t.string   "responsible_person"
  end

  add_index "alarms", ["alarm_level"], :name => "index_alarms_on_alarm_level"
  add_index "alarms", ["process_state"], :name => "index_alarms_on_process_state"
  add_index "alarms", ["responsible_person"], :name => "index_alarms_on_responsible_person"

  create_table "application_logs", :force => true do |t|
    t.date   "date"
    t.time   "time"
    t.string "user"
    t.string "message"
  end

  create_table "bookmarks", :force => true do |t|
    t.string  "title"
    t.text    "description"
    t.string  "table_name"
    t.string  "mode"
    t.string  "controller"
    t.string  "action"
    t.integer "identifier"
    t.date    "created_on"
  end

  create_table "charts", :force => true do |t|
    t.string  "name"
    t.string  "description"
    t.string  "column1"
    t.string  "column2"
    t.string  "aggregation_column"
    t.string  "aggregation_function"
    t.string  "chart_type"
    t.string  "order_by"
    t.integer "height"
    t.integer "width"
    t.string  "time_range",           :default => "yesterday"
    t.string  "column3"
    t.integer "max_values",           :default => 45
    t.boolean "stacked",              :default => false
    t.boolean "flipped",              :default => false,       :null => false
  end

  create_table "charts_report_templates", :id => false, :force => true do |t|
    t.integer "priority"
    t.integer "chart_id"
    t.integer "report_template_id"
    t.integer "view_id"
  end

  add_index "charts_report_templates", ["chart_id"], :name => "index_charts_report_templates_on_chart_id"
  add_index "charts_report_templates", ["report_template_id"], :name => "index_charts_report_templates_on_report_template_id"
  add_index "charts_report_templates", ["view_id"], :name => "index_charts_report_templates_on_view_id"

  create_table "connections", :force => true do |t|
    t.string   "name"
    t.string   "adapter"
    t.string   "host"
    t.string   "database"
    t.string   "username"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "filters", :force => true do |t|
    t.string "name"
    t.string "order_by"
    t.text   "yaml_declaration"
    t.text   "description"
  end

  create_table "ip_ranges", :force => true do |t|
    t.string  "name"
    t.text    "description"
    t.string  "from_ip"
    t.string  "to_ip"
    t.string  "netmask"
    t.boolean "enabled",     :default => true
  end

  create_table "ip_ranges_mappings", :force => true do |t|
    t.integer "ip_range1_id"
    t.integer "ip_range2_id"
    t.text    "description"
  end

  create_table "report_templates", :force => true do |t|
    t.string  "name"
    t.string  "description"
    t.string  "title"
    t.text    "text"
    t.integer "view_id"
    t.integer "version"
    t.date    "created_on"
    t.time    "created_at"
    t.date    "modified_on"
    t.time    "modified_at"
  end

  create_table "report_templates_tables", :id => false, :force => true do |t|
    t.integer "priority"
    t.integer "table_id"
    t.integer "report_template_id"
    t.integer "view_id"
  end

  add_index "report_templates_tables", ["report_template_id"], :name => "index_report_templates_tables_on_report_template_id"
  add_index "report_templates_tables", ["table_id"], :name => "index_report_templates_tables_on_table_id"
  add_index "report_templates_tables", ["view_id"], :name => "index_report_templates_tables_on_view_id"

  create_table "reports", :force => true do |t|
    t.string  "name"
    t.date    "date"
    t.time    "time"
    t.string  "path"
    t.integer "report_template_id"
    t.integer "sentinel_id"
    t.string  "generated_by"
    t.integer "alarm_id"
  end

  add_index "reports", ["alarm_id"], :name => "index_reports_on_alarm_id"
  add_index "reports", ["date"], :name => "index_reports_on_date"
  add_index "reports", ["generated_by"], :name => "index_reports_on_generated_by"
  add_index "reports", ["name"], :name => "index_reports_on_name"
  add_index "reports", ["report_template_id"], :name => "index_reports_on_report_template_id"
  add_index "reports", ["sentinel_id"], :name => "index_reports_on_sentinel_id"

  create_table "sentinels", :force => true do |t|
    t.string  "name"
    t.text    "description"
    t.integer "view_id"
    t.integer "threshold"
    t.boolean "send_ossim"
    t.boolean "send_mail"
    t.text    "mail_to"
    t.text    "external_program"
    t.text    "cron_interval"
    t.integer "report_template_id"
    t.integer "alarm_level"
    t.integer "action"
    t.string  "time_range",              :default => "yesterday"
    t.string  "filters"
    t.boolean "include_report_in_email", :default => true
    t.boolean "include_csv_in_email",    :default => true
  end

  add_index "sentinels", ["action"], :name => "index_sentinels_on_action"
  add_index "sentinels", ["alarm_level"], :name => "index_sentinels_on_alarm_level"
  add_index "sentinels", ["report_template_id"], :name => "index_sentinels_on_report_template_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "tables", :force => true do |t|
    t.string  "name"
    t.string  "description"
    t.string  "columns"
    t.integer "max_count"
    t.string  "group_by"
    t.string  "order_by"
    t.integer "max_display_count"
  end

  create_table "views", :force => true do |t|
    t.string  "name"
    t.text    "sql_declaration"
    t.text    "additional_fields"
    t.text    "date_column_name"
    t.text    "description"
    t.string  "exclusive_for_group"
    t.string  "id_source_table"
    t.boolean "do_not_use_view_for_query", :default => false
  end

end
