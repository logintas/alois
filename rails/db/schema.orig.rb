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
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 23) do

  create_table "ace_passcode_metas", :force => true do |t|
    t.string  "action",                 :limit => 40
    t.string  "login",                  :limit => 30
    t.string  "user_name",              :limit => 100
    t.string  "token",                  :limit => 15
    t.string  "group_name",             :limit => 100
    t.string  "site",                   :limit => 100
    t.string  "agent_host",             :limit => 100
    t.string  "server",                 :limit => 100
    t.integer "windows_event_metas_id"
    t.integer "log_metas_id"
  end

  add_index "ace_passcode_metas", ["action"], :name => "ace_passcode_metas_action_index"
  add_index "ace_passcode_metas", ["login"], :name => "ace_passcode_metas_login_index"
  add_index "ace_passcode_metas", ["user_name"], :name => "ace_passcode_metas_user_name_index"
  add_index "ace_passcode_metas", ["group_name"], :name => "ace_passcode_metas_group_index"
  add_index "ace_passcode_metas", ["site"], :name => "ace_passcode_metas_site_index"
  add_index "ace_passcode_metas", ["agent_host"], :name => "ace_passcode_metas_agent_host_index"
  add_index "ace_passcode_metas", ["server"], :name => "ace_passcode_metas_server_index"
  add_index "ace_passcode_metas", ["windows_event_metas_id"], :name => "ace_passcode_metas_windows_event_metas_id_index"
  add_index "ace_passcode_metas", ["log_metas_id"], :name => "ace_passcode_metas_log_metas_id_index"

  create_table "alarms", :force => true do |t|
    t.datetime "created_at"
    t.integer  "sentinel_id"
    t.string   "comment"
    t.boolean  "acknowledge"
    t.datetime "updated_at"
    t.string   "updated_by"
    t.binary   "log"
    t.string   "path"
    t.integer  "alarm_level"
  end

  add_index "alarms", ["alarm_level"], :name => "index_alarms_on_alarm_level"

  create_table "amavis_metas", :force => true do |t|
    t.integer "process_id"
    t.string  "amavis_id",     :limit => 20
    t.string  "action",        :limit => 20
    t.string  "status",        :limit => 20
    t.string  "from_field",    :limit => 50
    t.string  "to_field"
    t.string  "message_id",    :limit => 50
    t.string  "hits",          :limit => 10
    t.integer "process_time"
    t.string  "ip",            :limit => 50
    t.string  "signature",     :limit => 50
    t.string  "quarantine",    :limit => 50
    t.integer "pure_metas_id"
    t.integer "log_metas_id"
  end

  add_index "amavis_metas", ["action"], :name => "amavis_metas_action_index"
  add_index "amavis_metas", ["status"], :name => "amavis_metas_status_index"
  add_index "amavis_metas", ["from_field"], :name => "amavis_metas_from_field_index"
  add_index "amavis_metas", ["message_id"], :name => "amavis_metas_message_id_index"
  add_index "amavis_metas", ["ip"], :name => "amavis_metas_ip_index"
  add_index "amavis_metas", ["signature"], :name => "amavis_metas_signature_index"
  add_index "amavis_metas", ["pure_metas_id"], :name => "amavis_metas_pure_metas_id_index"
  add_index "amavis_metas", ["log_metas_id"], :name => "amavis_metas_log_metas_id_index"

  create_table "apache_file_metas", :force => true do |t|
    t.string  "virtual_host",  :limit => 100
    t.integer "file_metas_id"
  end

  add_index "apache_file_metas", ["file_metas_id"], :name => "apache_file_metas_file_metas_id_index"

  create_table "apache_log_metas", :force => true do |t|
    t.string  "forensic_id", :limit => 30
    t.integer "serve_time"
    t.string  "host",        :limit => 50
  end

  create_table "apache_metas", :force => true do |t|
    t.string  "remote_host",    :limit => 40
    t.string  "remote_logname", :limit => 20
    t.string  "remote_user",    :limit => 20
    t.time    "time"
    t.date    "date"
    t.string  "first_line",     :limit => 512
    t.integer "status"
    t.integer "bytes"
    t.string  "referer",        :limit => 40
    t.string  "useragent",      :limit => 40
    t.integer "log_metas_id"
    t.integer "pure_metas_id"
  end

  add_index "apache_metas", ["remote_host"], :name => "apache_metas_remote_host_index"
  add_index "apache_metas", ["remote_user"], :name => "apache_metas_remote_user_index"
  add_index "apache_metas", ["status"], :name => "apache_metas_status_index"
  add_index "apache_metas", ["useragent"], :name => "apache_metas_useragent_index"
  add_index "apache_metas", ["first_line"], :name => "apache_metas_first_line_index"
  add_index "apache_metas", ["log_metas_id"], :name => "apache_metas_log_metas_id_index"
  add_index "apache_metas", ["pure_metas_id"], :name => "apache_metas_pure_metas_id_index"

  create_table "archive_metas", :force => true do |t|
    t.string   "filename"
    t.integer  "current"
    t.integer  "total"
    t.integer  "todo"
    t.boolean  "finished",   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
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
  end

  create_table "charts_report_templates", :force => true do |t|
    t.integer "priority"
    t.integer "chart_id"
    t.integer "report_template_id"
    t.integer "view_id"
  end

  add_index "charts_report_templates", ["chart_id"], :name => "index_charts_report_templates_on_chart_id"
  add_index "charts_report_templates", ["report_template_id"], :name => "index_charts_report_templates_on_report_template_id"
  add_index "charts_report_templates", ["view_id"], :name => "index_charts_report_templates_on_view_id"

  create_table "cisco_base_metas", :force => true do |t|
    t.string  "ip",                          :limit => 40
    t.string  "message_type",                :limit => 10
    t.integer "severity"
    t.integer "message_number"
    t.integer "log_metas_id"
    t.integer "syslogd_small_base_metas_id"
  end

  add_index "cisco_base_metas", ["ip"], :name => "cisco_base_metas_ip_index"
  add_index "cisco_base_metas", ["message_type"], :name => "cisco_base_metas_message_type_index"
  add_index "cisco_base_metas", ["severity"], :name => "cisco_base_metas_severity_index"
  add_index "cisco_base_metas", ["log_metas_id"], :name => "cisco_base_metas_log_metas_id_index"
  add_index "cisco_base_metas", ["syslogd_small_base_metas_id"], :name => "cisco_base_metas_syslogd_small_base_metas_id_index"

  create_table "cisco_firewall_connection_metas", :force => true do |t|
    t.string  "msg",                 :limit => 30
    t.string  "reason",              :limit => 30
    t.integer "connection_id"
    t.string  "connection_type",     :limit => 10
    t.string  "foreign_name",        :limit => 30
    t.string  "foreign_ip",          :limit => 40
    t.string  "foreign_port",        :limit => 10
    t.string  "local_name",          :limit => 30
    t.string  "local_ip",            :limit => 40
    t.string  "local_port",          :limit => 10
    t.string  "global_to_ip",        :limit => 40
    t.string  "global_to_port",      :limit => 10
    t.string  "global_from_ip",      :limit => 40
    t.string  "global_from_port",    :limit => 10
    t.time    "duration"
    t.integer "bytes"
    t.integer "cisco_base_metas_id"
    t.integer "log_metas_id"
  end

  add_index "cisco_firewall_connection_metas", ["connection_id"], :name => "cisco_firewall_connection_metas_connection_id_index"
  add_index "cisco_firewall_connection_metas", ["connection_type"], :name => "cisco_firewall_connection_metas_connection_type_index"
  add_index "cisco_firewall_connection_metas", ["reason"], :name => "cisco_firewall_connection_metas_reason_index"
  add_index "cisco_firewall_connection_metas", ["foreign_name"], :name => "cisco_firewall_connection_metas_foreign_name_index"
  add_index "cisco_firewall_connection_metas", ["foreign_ip"], :name => "cisco_firewall_connection_metas_foreign_ip_index"
  add_index "cisco_firewall_connection_metas", ["foreign_port"], :name => "cisco_firewall_connection_metas_foreign_port_index"
  add_index "cisco_firewall_connection_metas", ["local_name"], :name => "cisco_firewall_connection_metas_local_name_index"
  add_index "cisco_firewall_connection_metas", ["local_ip"], :name => "cisco_firewall_connection_metas_local_ip_index"
  add_index "cisco_firewall_connection_metas", ["local_port"], :name => "cisco_firewall_connection_metas_local_port_index"
  add_index "cisco_firewall_connection_metas", ["global_to_ip"], :name => "cisco_firewall_connection_metas_global_to_ip_index"
  add_index "cisco_firewall_connection_metas", ["global_to_port"], :name => "cisco_firewall_connection_metas_global_to_port_index"
  add_index "cisco_firewall_connection_metas", ["global_from_ip"], :name => "cisco_firewall_connection_metas_global_from_ip_index"
  add_index "cisco_firewall_connection_metas", ["global_from_port"], :name => "cisco_firewall_connection_metas_global_from_port_index"
  add_index "cisco_firewall_connection_metas", ["cisco_base_metas_id"], :name => "cisco_firewall_connection_metas_cisco_base_metas_id_index"
  add_index "cisco_firewall_connection_metas", ["log_metas_id"], :name => "cisco_firewall_connection_metas_log_metas_id_index"

  create_table "cisco_firewall_metas", :force => true do |t|
    t.string  "msg",                 :limit => 100
    t.string  "source",              :limit => 40
    t.string  "source_port",         :limit => 10
    t.string  "destination",         :limit => 40
    t.string  "destination_port",    :limit => 10
    t.string  "interface",           :limit => 20
    t.integer "cisco_base_metas_id"
  end

  add_index "cisco_firewall_metas", ["source"], :name => "cisco_firewall_metas_source_index"
  add_index "cisco_firewall_metas", ["source_port"], :name => "cisco_firewall_metas_source_port_index"
  add_index "cisco_firewall_metas", ["destination"], :name => "cisco_firewall_metas_destination_index"
  add_index "cisco_firewall_metas", ["destination_port"], :name => "cisco_firewall_metas_destination_port_index"
  add_index "cisco_firewall_metas", ["interface"], :name => "cisco_firewall_metas_interface_index"
  add_index "cisco_firewall_metas", ["cisco_base_metas_id"], :name => "cisco_firewall_metas_cisco_base_metas_id_index"

  create_table "cisco_metas", :force => true do |t|
    t.string  "msg",                 :limit => 100
    t.string  "server",              :limit => 40
    t.string  "server_port",         :limit => 10
    t.string  "name",                :limit => 40
    t.string  "ip",                  :limit => 40
    t.string  "port",                :limit => 10
    t.string  "user",                :limit => 20
    t.string  "group_name",          :limit => 20
    t.string  "reason",              :limit => 100
    t.integer "cisco_base_metas_id"
  end

  add_index "cisco_metas", ["msg"], :name => "cisco_metas_msg_index"
  add_index "cisco_metas", ["server"], :name => "cisco_metas_server_index"
  add_index "cisco_metas", ["server_port"], :name => "cisco_metas_server_port_index"
  add_index "cisco_metas", ["name"], :name => "cisco_metas_name_index"
  add_index "cisco_metas", ["ip"], :name => "cisco_metas_ip_index"
  add_index "cisco_metas", ["port"], :name => "cisco_metas_port_index"
  add_index "cisco_metas", ["user"], :name => "cisco_metas_user_index"
  add_index "cisco_metas", ["group_name"], :name => "cisco_metas_group_name_index"
  add_index "cisco_metas", ["cisco_base_metas_id"], :name => "cisco_metas_cisco_base_metas_id_index"

  create_table "cisco_session_metas", :force => true do |t|
    t.string  "msg",            :limit => 100
    t.string  "session_type",   :limit => 30
    t.time    "duration"
    t.integer "in_bytes"
    t.integer "out_bytes"
    t.integer "cisco_metas_id"
  end

  add_index "cisco_session_metas", ["msg"], :name => "index_cisco_session_metas_on_msg"
  add_index "cisco_session_metas", ["session_type"], :name => "index_cisco_session_metas_on_session_type"
  add_index "cisco_session_metas", ["cisco_metas_id"], :name => "index_cisco_session_metas_on_cisco_metas_id"

  create_table "cron_metas", :force => true do |t|
    t.integer "process_id"
    t.string  "user",          :limit => 20
    t.integer "uid"
    t.string  "program",       :limit => 20
    t.string  "action",        :limit => 20
    t.string  "command"
    t.integer "pure_metas_id"
    t.integer "log_metas_id"
  end

  add_index "cron_metas", ["user"], :name => "cron_metas_user_index"
  add_index "cron_metas", ["uid"], :name => "cron_metas_uid_index"
  add_index "cron_metas", ["program"], :name => "cron_metas_program_index"
  add_index "cron_metas", ["action"], :name => "cron_metas_action_index"
  add_index "cron_metas", ["pure_metas_id"], :name => "cron_metas_pure_metas_id_index"
  add_index "cron_metas", ["log_metas_id"], :name => "cron_metas_log_metas_id_index"

  create_table "fetchmail_metas", :force => true do |t|
    t.integer "process_id"
    t.string  "program",       :limit => 20
    t.string  "action",        :limit => 200
    t.integer "pure_metas_id"
    t.integer "log_metas_id"
  end

  add_index "fetchmail_metas", ["program"], :name => "fetchmail_metas_program_index"
  add_index "fetchmail_metas", ["action"], :name => "fetchmail_metas_action_index"
  add_index "fetchmail_metas", ["pure_metas_id"], :name => "fetchmail_metas_pure_metas_id_index"
  add_index "fetchmail_metas", ["log_metas_id"], :name => "fetchmail_metas_log_metas_id_index"

  create_table "file_metas", :force => true do |t|
    t.string   "dirname"
    t.string   "basename"
    t.string   "ftype",              :limit => 20
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
    t.integer  "source_db_metas_id"
    t.integer  "archive_metas_id"
  end

  add_index "file_metas", ["source_db_metas_id"], :name => "file_metas_source_db_metas_id_index"
  add_index "file_metas", ["archive_metas_id"], :name => "file_metas_archive_metas_id_index"

  create_table "filters", :force => true do |t|
    t.string "name"
    t.string "order_by"
    t.text   "yaml_declaration"
    t.text   "description"
  end

  create_table "inet_header_metas", :force => true do |t|
    t.date    "date"
    t.time    "time"
    t.integer "milliseconds"
    t.string  "severity",        :limit => 10
    t.string  "system_id",       :limit => 30
    t.string  "msg_id",          :limit => 30
    t.string  "user_id",         :limit => 30
    t.string  "eventtype",       :limit => 30
    t.integer "pure_metas_id"
    t.integer "log_metas_id"
    t.string  "client_ip",       :limit => 32
    t.string  "server_ip",       :limit => 32
    t.string  "session_id",      :limit => 32
    t.integer "hit_number"
    t.integer "num_object_hits"
    t.string  "text1",           :limit => 1024
    t.string  "text2",           :limit => 1024
  end

  add_index "inet_header_metas", ["date"], :name => "index_inet_header_metas_on_date"
  add_index "inet_header_metas", ["severity"], :name => "index_inet_header_metas_on_severity"
  add_index "inet_header_metas", ["system_id"], :name => "index_inet_header_metas_on_system_id"
  add_index "inet_header_metas", ["msg_id"], :name => "index_inet_header_metas_on_msg_id"
  add_index "inet_header_metas", ["user_id"], :name => "index_inet_header_metas_on_user_id"
  add_index "inet_header_metas", ["eventtype"], :name => "index_inet_header_metas_on_eventtype"
  add_index "inet_header_metas", ["pure_metas_id"], :name => "index_inet_header_metas_on_pure_metas_id"
  add_index "inet_header_metas", ["log_metas_id"], :name => "index_inet_header_metas_on_log_metas_id"
  add_index "inet_header_metas", ["client_ip"], :name => "index_inet_header_metas_on_client_ip"
  add_index "inet_header_metas", ["server_ip"], :name => "index_inet_header_metas_on_server_ip"
  add_index "inet_header_metas", ["session_id"], :name => "index_inet_header_metas_on_session_id"
  add_index "inet_header_metas", ["hit_number"], :name => "index_inet_header_metas_on_hit_number"
  add_index "inet_header_metas", ["num_object_hits"], :name => "index_inet_header_metas_on_num_object_hits"

  create_table "inet_object_metas", :force => true do |t|
    t.string  "objecttype",           :limit => 30
    t.string  "object_id",            :limit => 512
    t.string  "version",              :limit => 30
    t.string  "filename",             :limit => 256
    t.string  "description",          :limit => 256
    t.string  "object_hashes",        :limit => 256
    t.string  "object_url",           :limit => 512
    t.integer "inet_header_metas_id"
    t.integer "inet_object_metas_id"
  end

  add_index "inet_object_metas", ["objecttype"], :name => "index_inet_object_metas_on_objecttype"
  add_index "inet_object_metas", ["object_id"], :name => "index_inet_object_metas_on_object_id"
  add_index "inet_object_metas", ["version"], :name => "index_inet_object_metas_on_version"
  add_index "inet_object_metas", ["filename"], :name => "index_inet_object_metas_on_filename"
  add_index "inet_object_metas", ["object_hashes"], :name => "index_inet_object_metas_on_object_hashes"
  add_index "inet_object_metas", ["object_url"], :name => "index_inet_object_metas_on_object_url"
  add_index "inet_object_metas", ["inet_header_metas_id"], :name => "index_inet_object_metas_on_inet_header_metas_id"
  add_index "inet_object_metas", ["inet_object_metas_id"], :name => "index_inet_object_metas_on_inet_object_metas_id"

  create_table "iptables_firewall_metas", :force => true do |t|
    t.string  "rule",          :limit => 10
    t.string  "src",           :limit => 20
    t.string  "spt",           :limit => 10
    t.string  "dst",           :limit => 20
    t.string  "dpt",           :limit => 10
    t.string  "custom",        :limit => 20
    t.string  "in",            :limit => 10
    t.string  "out",           :limit => 10
    t.string  "physin",        :limit => 10
    t.string  "physout",       :limit => 10
    t.integer "len"
    t.string  "tos",           :limit => 10
    t.string  "prec",          :limit => 10
    t.integer "ttl"
    t.integer "identifier"
    t.string  "proto",         :limit => 10
    t.string  "additional",    :limit => 20
    t.integer "pure_metas_id"
    t.integer "log_metas_id"
  end

  add_index "iptables_firewall_metas", ["rule"], :name => "iptables_firewall_metas_rule_index"
  add_index "iptables_firewall_metas", ["src"], :name => "iptables_firewall_metas_src_index"
  add_index "iptables_firewall_metas", ["spt"], :name => "iptables_firewall_metas_spt_index"
  add_index "iptables_firewall_metas", ["dst"], :name => "iptables_firewall_metas_dst_index"
  add_index "iptables_firewall_metas", ["dpt"], :name => "iptables_firewall_metas_dpt_index"
  add_index "iptables_firewall_metas", ["proto"], :name => "iptables_firewall_metas_proto_index"
  add_index "iptables_firewall_metas", ["log_metas_id"], :name => "iptables_firewall_metas_log_metas_id_index"
  add_index "iptables_firewall_metas", ["pure_metas_id"], :name => "iptables_firewall_metas_pure_metas_id_index"

  create_table "log_metas", :force => true do |t|
    t.date    "date"
    t.time    "time"
    t.string  "host"
    t.integer "hash_value"
    t.integer "syslogd_metas_id"
    t.integer "pure_metas_id"
    t.integer "file_metas_id"
  end

  add_index "log_metas", ["syslogd_metas_id"], :name => "log_metas_syslogd_metas_id_index"
  add_index "log_metas", ["pure_metas_id"], :name => "log_metas_pure_metas_id_index"
  add_index "log_metas", ["file_metas_id"], :name => "log_metas_file_metas_id_index"
  add_index "log_metas", ["date"], :name => "log_metas_date_index"
  add_index "log_metas", ["host"], :name => "log_metas_host_index"
  add_index "log_metas", ["hash_value"], :name => "log_metas_hash_value_index"

  create_table "messages", :force => true do |t|
    t.integer "meta_id"
    t.binary  "msg"
    t.string  "meta_type_name", :limit => 100
  end

  add_index "messages", ["meta_id"], :name => "messages_meta_id_index"
  add_index "messages", ["meta_type_name"], :name => "messages_meta_type_name_index"

  create_table "metas", :force => true do |t|
    t.integer "parent_id"
    t.string  "meta_type_name", :limit => 100
    t.integer "meta_id"
  end

  add_index "metas", ["parent_id"], :name => "metas_parent_id_index"
  add_index "metas", ["meta_type_name"], :name => "metas_meta_type_name_index"
  add_index "metas", ["meta_id"], :name => "metas_meta_id_index"

  create_table "nagios_metas", :force => true do |t|
    t.string  "msg_type",       :limit => 50
    t.string  "probed_by_host", :limit => 50
    t.string  "affected_host",  :limit => 50
    t.string  "service",        :limit => 20
    t.string  "status",         :limit => 20
    t.string  "unknown_1",      :limit => 20
    t.integer "unknown_2"
    t.string  "output"
    t.integer "pure_metas_id"
    t.integer "log_metas_id"
  end

  add_index "nagios_metas", ["msg_type"], :name => "nagios_metas_msg_type_index"
  add_index "nagios_metas", ["probed_by_host"], :name => "nagios_metas_probed_by_host_index"
  add_index "nagios_metas", ["affected_host"], :name => "nagios_metas_affected_host_index"
  add_index "nagios_metas", ["service"], :name => "nagios_metas_service_index"
  add_index "nagios_metas", ["status"], :name => "nagios_metas_status_index"
  add_index "nagios_metas", ["pure_metas_id"], :name => "nagios_metas_pure_metas_id_index"
  add_index "nagios_metas", ["log_metas_id"], :name => "nagios_metas_log_metas_id_index"

  create_table "nonyms", :force => true do |t|
    t.string "real_name", :limit => 20
  end

  add_index "nonyms", ["real_name"], :name => "nonyms_real_name_index"

  create_table "ovpn_base_metas", :force => true do |t|
    t.string  "vpn",           :limit => 20
    t.integer "process_id"
    t.string  "client_ip",     :limit => 50
    t.integer "client_port"
    t.string  "cert",          :limit => 50
    t.string  "msg_type",      :limit => 50
    t.string  "msg"
    t.string  "client",        :limit => 20
    t.integer "pure_metas_id"
    t.integer "log_metas_id"
  end

  add_index "ovpn_base_metas", ["vpn"], :name => "ovpn_base_metas_vpn_index"
  add_index "ovpn_base_metas", ["client_ip"], :name => "ovpn_base_metas_client_ip_index"
  add_index "ovpn_base_metas", ["client_port"], :name => "ovpn_base_metas_client_port_index"
  add_index "ovpn_base_metas", ["cert"], :name => "ovpn_base_metas_cert_index"
  add_index "ovpn_base_metas", ["msg_type"], :name => "ovpn_base_metas_msg_type_index"
  add_index "ovpn_base_metas", ["pure_metas_id"], :name => "ovpn_base_metas_pure_metas_id_index"
  add_index "ovpn_base_metas", ["log_metas_id"], :name => "ovpn_base_metas_log_metas_id_index"

  create_table "postfix_detail_metas", :force => true do |t|
    t.string  "message_id",       :limit => 50
    t.string  "from",             :limit => 50
    t.string  "to",               :limit => 50
    t.string  "orig_to",          :limit => 50
    t.string  "relay_host",       :limit => 50
    t.string  "relay_ip",         :limit => 50
    t.integer "delay"
    t.integer "size"
    t.integer "nrcpt"
    t.string  "status",           :limit => 20
    t.string  "command",          :limit => 200
    t.integer "postfix_metas_id"
  end

  add_index "postfix_detail_metas", ["relay_host"], :name => "postfix_detail_metas_relay_host_index"
  add_index "postfix_detail_metas", ["relay_ip"], :name => "postfix_detail_metas_relay_ip_index"
  add_index "postfix_detail_metas", ["delay"], :name => "postfix_detail_metas_delay_index"
  add_index "postfix_detail_metas", ["status"], :name => "postfix_detail_metas_status_index"
  add_index "postfix_detail_metas", ["postfix_metas_id"], :name => "postfix_detail_metas_postfix_metas_id_index"

  create_table "postfix_metas", :force => true do |t|
    t.string  "program",         :limit => 10
    t.integer "process_id"
    t.string  "mail_message_id", :limit => 10
    t.string  "action",          :limit => 40
    t.string  "host",            :limit => 50
    t.string  "ip",              :limit => 50
    t.integer "pure_metas_id"
    t.integer "log_metas_id"
  end

  add_index "postfix_metas", ["program"], :name => "postfix_metas_program_index"
  add_index "postfix_metas", ["action"], :name => "postfix_metas_action_index"
  add_index "postfix_metas", ["mail_message_id"], :name => "postfix_metas_mail_message_id_index"
  add_index "postfix_metas", ["host"], :name => "postfix_metas_host_index"
  add_index "postfix_metas", ["ip"], :name => "postfix_metas_ip_index"
  add_index "postfix_metas", ["pure_metas_id"], :name => "postfix_metas_pure_metas_id_index"
  add_index "postfix_metas", ["log_metas_id"], :name => "postfix_metas_log_metas_id_index"

  create_table "pure_metas", :force => true do |t|
    t.integer "file_metas_id"
  end

  add_index "pure_metas", ["file_metas_id"], :name => "pure_metas_file_metas_id_index"

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

  create_table "report_templates_tables", :force => true do |t|
    t.integer "priority"
    t.integer "table_id"
    t.integer "report_template_id"
    t.integer "view_id"
  end

  add_index "report_templates_tables", ["table_id"], :name => "index_report_templates_tables_on_table_id"
  add_index "report_templates_tables", ["report_template_id"], :name => "index_report_templates_tables_on_report_template_id"
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
    t.string  "time_range",         :default => "yesterday"
  end

  add_index "sentinels", ["report_template_id"], :name => "index_sentinels_on_report_template_id"
  add_index "sentinels", ["alarm_level"], :name => "index_sentinels_on_alarm_level"
  add_index "sentinels", ["action"], :name => "index_sentinels_on_action"

  create_table "source_db_metas", :force => true do |t|
    t.string   "process_type",   :limit => 10
    t.integer  "start"
    t.integer  "current"
    t.integer  "total"
    t.integer  "todo"
    t.integer  "count"
    t.string   "raw_class_name", :limit => 20
    t.boolean  "execute_once"
    t.integer  "waiting_time"
    t.boolean  "finished",                     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "syslogd_metas", :force => true do |t|
    t.string  "ip",                 :limit => 40
    t.string  "facility",           :limit => 10
    t.string  "priority",           :limit => 10
    t.string  "level",              :limit => 10
    t.string  "tag",                :limit => 10
    t.integer "program",            :limit => 15
    t.integer "source_db_metas_id"
    t.integer "archive_metas_id"
  end

  add_index "syslogd_metas", ["ip"], :name => "syslogd_metas_ip_index"
  add_index "syslogd_metas", ["program"], :name => "syslogd_metas_program_index"
  add_index "syslogd_metas", ["source_db_metas_id"], :name => "syslogd_metas_source_db_metas_id_index"
  add_index "syslogd_metas", ["archive_metas_id"], :name => "syslogd_metas_archive_metas_id_index"

  create_table "syslogd_small_base_metas", :force => true do |t|
    t.date    "date"
    t.time    "time"
    t.string  "level",         :limit => 10
    t.string  "ip",            :limit => 40
    t.integer "hash_value"
    t.integer "pure_metas_id"
    t.integer "log_metas_id"
  end

  add_index "syslogd_small_base_metas", ["date"], :name => "syslogd_small_base_metas_date_index"
  add_index "syslogd_small_base_metas", ["level"], :name => "syslogd_small_base_metas_level_index"
  add_index "syslogd_small_base_metas", ["ip"], :name => "syslogd_small_base_metas_ip_index"
  add_index "syslogd_small_base_metas", ["hash_value"], :name => "syslogd_small_base_metas_hash_value_index"
  add_index "syslogd_small_base_metas", ["pure_metas_id"], :name => "syslogd_small_base_metas_pure_metas_id_index"
  add_index "syslogd_small_base_metas", ["log_metas_id"], :name => "syslogd_small_base_metas_log_metas_id_index"

  create_table "tables", :force => true do |t|
    t.string  "name"
    t.string  "description"
    t.string  "columns"
    t.integer "max_count"
  end

  create_table "tables_report_teplates", :force => true do |t|
    t.integer "priority"
    t.integer "table_id"
    t.integer "report_template_id"
    t.integer "view_id"
  end

  create_table "test_metas", :force => true do |t|
    t.string  "message"
    t.integer "pure_metas_id"
    t.integer "log_metas_id"
  end

  add_index "test_metas", ["log_metas_id"], :name => "test_metas_log_metas_id_index"
  add_index "test_metas", ["pure_metas_id"], :name => "test_metas_pure_metas_id_index"

  create_table "views", :force => true do |t|
    t.string "name"
    t.text   "sql_declaration"
    t.text   "additional_fields"
    t.text   "date_column_name"
    t.text   "description"
    t.string "exclusive_for_group"
    t.string "id_source_table"
  end

  create_table "windows_event_metas", :force => true do |t|
    t.string  "log_name",      :limit => 30
    t.integer "field1"
    t.string  "event_type",    :limit => 20
    t.integer "field3"
    t.date    "date"
    t.time    "time"
    t.integer "event_id"
    t.string  "source",        :limit => 30
    t.string  "user"
    t.string  "category",      :limit => 30
    t.string  "level",         :limit => 30
    t.string  "computer"
    t.string  "facility",      :limit => 30
    t.binary  "data"
    t.integer "field14"
    t.integer "pure_metas_id"
    t.integer "log_metas_id"
  end

  add_index "windows_event_metas", ["log_name"], :name => "windows_event_metas_log_name_index"
  add_index "windows_event_metas", ["event_type"], :name => "windows_event_metas_event_type_index"
  add_index "windows_event_metas", ["date"], :name => "windows_event_metas_date_index"
  add_index "windows_event_metas", ["user"], :name => "windows_event_metas_user_index"
  add_index "windows_event_metas", ["source"], :name => "windows_event_metas_source_index"
  add_index "windows_event_metas", ["category"], :name => "windows_event_metas_category_index"
  add_index "windows_event_metas", ["level"], :name => "windows_event_metas_message_level_index"
  add_index "windows_event_metas", ["computer"], :name => "windows_event_metas_computer_index"
  add_index "windows_event_metas", ["facility"], :name => "windows_event_metas_facility_index"
  add_index "windows_event_metas", ["pure_metas_id"], :name => "windows_event_metas_pure_metas_id_index"
  add_index "windows_event_metas", ["log_metas_id"], :name => "windows_event_metas_log_metasid_index"

end
