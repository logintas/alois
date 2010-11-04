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

ActiveRecord::Schema.define(:version => 0) do

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
  add_index "ace_passcode_metas", ["agent_host"], :name => "ace_passcode_metas_agent_host_index"
  add_index "ace_passcode_metas", ["group_name"], :name => "ace_passcode_metas_group_index"
  add_index "ace_passcode_metas", ["log_metas_id"], :name => "ace_passcode_metas_log_metas_id_index"
  add_index "ace_passcode_metas", ["login"], :name => "ace_passcode_metas_login_index"
  add_index "ace_passcode_metas", ["server"], :name => "ace_passcode_metas_server_index"
  add_index "ace_passcode_metas", ["site"], :name => "ace_passcode_metas_site_index"
  add_index "ace_passcode_metas", ["user_name"], :name => "ace_passcode_metas_user_name_index"
  add_index "ace_passcode_metas", ["windows_event_metas_id"], :name => "ace_passcode_metas_windows_event_metas_id_index"

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
  add_index "amavis_metas", ["from_field"], :name => "amavis_metas_from_field_index"
  add_index "amavis_metas", ["ip"], :name => "amavis_metas_ip_index"
  add_index "amavis_metas", ["log_metas_id"], :name => "amavis_metas_log_metas_id_index"
  add_index "amavis_metas", ["message_id"], :name => "amavis_metas_message_id_index"
  add_index "amavis_metas", ["pure_metas_id"], :name => "amavis_metas_pure_metas_id_index"
  add_index "amavis_metas", ["signature"], :name => "amavis_metas_signature_index"
  add_index "amavis_metas", ["status"], :name => "amavis_metas_status_index"

  create_table "apache_file_metas", :force => true do |t|
    t.string  "virtual_host",  :limit => 100
    t.integer "file_metas_id"
  end

  add_index "apache_file_metas", ["file_metas_id"], :name => "apache_file_metas_file_metas_id_index"

  create_table "apache_log_metas", :force => true do |t|
    t.string  "forensic_id",  :limit => 30
    t.integer "serve_time"
    t.string  "host",         :limit => 50
    t.integer "log_metas_id"
  end

  add_index "apache_log_metas", ["log_metas_id"], :name => "index_apache_log_metas_on_log_metas_id"

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

  add_index "apache_metas", ["first_line"], :name => "apache_metas_first_line_index"
  add_index "apache_metas", ["log_metas_id"], :name => "apache_metas_log_metas_id_index"
  add_index "apache_metas", ["pure_metas_id"], :name => "apache_metas_pure_metas_id_index"
  add_index "apache_metas", ["remote_host"], :name => "apache_metas_remote_host_index"
  add_index "apache_metas", ["remote_user"], :name => "apache_metas_remote_user_index"
  add_index "apache_metas", ["status"], :name => "apache_metas_status_index"
  add_index "apache_metas", ["useragent"], :name => "apache_metas_useragent_index"

  create_table "archive_metas", :force => true do |t|
    t.string   "filename"
    t.integer  "current"
    t.integer  "total"
    t.integer  "todo"
    t.boolean  "finished",   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cisco_base_metas", :force => true do |t|
    t.string  "ip",                          :limit => 40
    t.string  "message_type",                :limit => 10
    t.integer "severity"
    t.integer "message_number"
    t.integer "log_metas_id"
    t.integer "syslogd_small_base_metas_id"
  end

  add_index "cisco_base_metas", ["ip"], :name => "cisco_base_metas_ip_index"
  add_index "cisco_base_metas", ["log_metas_id"], :name => "cisco_base_metas_log_metas_id_index"
  add_index "cisco_base_metas", ["message_type"], :name => "cisco_base_metas_message_type_index"
  add_index "cisco_base_metas", ["severity"], :name => "cisco_base_metas_severity_index"
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
    t.string  "user",                :limit => 20
  end

  add_index "cisco_firewall_connection_metas", ["cisco_base_metas_id"], :name => "cisco_firewall_connection_metas_cisco_base_metas_id_index"
  add_index "cisco_firewall_connection_metas", ["connection_id"], :name => "cisco_firewall_connection_metas_connection_id_index"
  add_index "cisco_firewall_connection_metas", ["connection_type"], :name => "cisco_firewall_connection_metas_connection_type_index"
  add_index "cisco_firewall_connection_metas", ["foreign_ip"], :name => "cisco_firewall_connection_metas_foreign_ip_index"
  add_index "cisco_firewall_connection_metas", ["foreign_name"], :name => "cisco_firewall_connection_metas_foreign_name_index"
  add_index "cisco_firewall_connection_metas", ["foreign_port"], :name => "cisco_firewall_connection_metas_foreign_port_index"
  add_index "cisco_firewall_connection_metas", ["global_from_ip"], :name => "cisco_firewall_connection_metas_global_from_ip_index"
  add_index "cisco_firewall_connection_metas", ["global_from_port"], :name => "cisco_firewall_connection_metas_global_from_port_index"
  add_index "cisco_firewall_connection_metas", ["global_to_ip"], :name => "cisco_firewall_connection_metas_global_to_ip_index"
  add_index "cisco_firewall_connection_metas", ["global_to_port"], :name => "cisco_firewall_connection_metas_global_to_port_index"
  add_index "cisco_firewall_connection_metas", ["local_ip"], :name => "cisco_firewall_connection_metas_local_ip_index"
  add_index "cisco_firewall_connection_metas", ["local_name"], :name => "cisco_firewall_connection_metas_local_name_index"
  add_index "cisco_firewall_connection_metas", ["local_port"], :name => "cisco_firewall_connection_metas_local_port_index"
  add_index "cisco_firewall_connection_metas", ["log_metas_id"], :name => "cisco_firewall_connection_metas_log_metas_id_index"
  add_index "cisco_firewall_connection_metas", ["reason"], :name => "cisco_firewall_connection_metas_reason_index"

  create_table "cisco_firewall_metas", :force => true do |t|
    t.string  "msg",                 :limit => 100
    t.string  "source",              :limit => 40
    t.string  "source_port",         :limit => 10
    t.string  "destination",         :limit => 40
    t.string  "destination_port",    :limit => 10
    t.string  "interface",           :limit => 20
    t.integer "cisco_base_metas_id"
  end

  add_index "cisco_firewall_metas", ["cisco_base_metas_id"], :name => "cisco_firewall_metas_cisco_base_metas_id_index"
  add_index "cisco_firewall_metas", ["destination"], :name => "cisco_firewall_metas_destination_index"
  add_index "cisco_firewall_metas", ["destination_port"], :name => "cisco_firewall_metas_destination_port_index"
  add_index "cisco_firewall_metas", ["interface"], :name => "cisco_firewall_metas_interface_index"
  add_index "cisco_firewall_metas", ["source"], :name => "cisco_firewall_metas_source_index"
  add_index "cisco_firewall_metas", ["source_port"], :name => "cisco_firewall_metas_source_port_index"

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

  add_index "cisco_metas", ["cisco_base_metas_id"], :name => "cisco_metas_cisco_base_metas_id_index"
  add_index "cisco_metas", ["group_name"], :name => "cisco_metas_group_name_index"
  add_index "cisco_metas", ["ip"], :name => "cisco_metas_ip_index"
  add_index "cisco_metas", ["msg"], :name => "cisco_metas_msg_index"
  add_index "cisco_metas", ["name"], :name => "cisco_metas_name_index"
  add_index "cisco_metas", ["port"], :name => "cisco_metas_port_index"
  add_index "cisco_metas", ["server"], :name => "cisco_metas_server_index"
  add_index "cisco_metas", ["server_port"], :name => "cisco_metas_server_port_index"
  add_index "cisco_metas", ["user"], :name => "cisco_metas_user_index"

  create_table "cisco_session_metas", :force => true do |t|
    t.string  "msg",            :limit => 100
    t.string  "session_type",   :limit => 30
    t.time    "duration"
    t.integer "in_bytes"
    t.integer "out_bytes"
    t.integer "cisco_metas_id"
  end

  add_index "cisco_session_metas", ["cisco_metas_id"], :name => "index_cisco_session_metas_on_cisco_metas_id"
  add_index "cisco_session_metas", ["msg"], :name => "index_cisco_session_metas_on_msg"
  add_index "cisco_session_metas", ["session_type"], :name => "index_cisco_session_metas_on_session_type"

  create_table "compression_metas", :force => true do |t|
    t.string  "extname"
    t.string  "inflate_command"
    t.integer "inflated_size"
    t.integer "deflated_size"
    t.integer "file_metas_id"
  end

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

  add_index "cron_metas", ["action"], :name => "cron_metas_action_index"
  add_index "cron_metas", ["log_metas_id"], :name => "cron_metas_log_metas_id_index"
  add_index "cron_metas", ["program"], :name => "cron_metas_program_index"
  add_index "cron_metas", ["pure_metas_id"], :name => "cron_metas_pure_metas_id_index"
  add_index "cron_metas", ["uid"], :name => "cron_metas_uid_index"
  add_index "cron_metas", ["user"], :name => "cron_metas_user_index"

  create_table "fetchmail_metas", :force => true do |t|
    t.integer "process_id"
    t.string  "program",       :limit => 20
    t.string  "action",        :limit => 200
    t.integer "pure_metas_id"
    t.integer "log_metas_id"
  end

  add_index "fetchmail_metas", ["action"], :name => "fetchmail_metas_action_index"
  add_index "fetchmail_metas", ["log_metas_id"], :name => "fetchmail_metas_log_metas_id_index"
  add_index "fetchmail_metas", ["program"], :name => "fetchmail_metas_program_index"
  add_index "fetchmail_metas", ["pure_metas_id"], :name => "fetchmail_metas_pure_metas_id_index"

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

  add_index "file_metas", ["archive_metas_id"], :name => "file_metas_archive_metas_id_index"
  add_index "file_metas", ["source_db_metas_id"], :name => "file_metas_source_db_metas_id_index"

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

  add_index "inet_header_metas", ["client_ip"], :name => "index_inet_header_metas_on_client_ip"
  add_index "inet_header_metas", ["date"], :name => "index_inet_header_metas_on_date"
  add_index "inet_header_metas", ["eventtype"], :name => "index_inet_header_metas_on_eventtype"
  add_index "inet_header_metas", ["hit_number"], :name => "index_inet_header_metas_on_hit_number"
  add_index "inet_header_metas", ["log_metas_id"], :name => "index_inet_header_metas_on_log_metas_id"
  add_index "inet_header_metas", ["msg_id"], :name => "index_inet_header_metas_on_msg_id"
  add_index "inet_header_metas", ["num_object_hits"], :name => "index_inet_header_metas_on_num_object_hits"
  add_index "inet_header_metas", ["pure_metas_id"], :name => "index_inet_header_metas_on_pure_metas_id"
  add_index "inet_header_metas", ["server_ip"], :name => "index_inet_header_metas_on_server_ip"
  add_index "inet_header_metas", ["session_id"], :name => "index_inet_header_metas_on_session_id"
  add_index "inet_header_metas", ["severity"], :name => "index_inet_header_metas_on_severity"
  add_index "inet_header_metas", ["system_id"], :name => "index_inet_header_metas_on_system_id"
  add_index "inet_header_metas", ["user_id"], :name => "index_inet_header_metas_on_user_id"

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
    t.string  "object_location",      :limit => 512
  end

  add_index "inet_object_metas", ["filename"], :name => "index_inet_object_metas_on_filename"
  add_index "inet_object_metas", ["inet_header_metas_id"], :name => "index_inet_object_metas_on_inet_header_metas_id"
  add_index "inet_object_metas", ["inet_object_metas_id"], :name => "index_inet_object_metas_on_inet_object_metas_id"
  add_index "inet_object_metas", ["object_hashes"], :name => "index_inet_object_metas_on_object_hashes"
  add_index "inet_object_metas", ["object_id"], :name => "index_inet_object_metas_on_object_id"
  add_index "inet_object_metas", ["object_url"], :name => "index_inet_object_metas_on_object_url"
  add_index "inet_object_metas", ["objecttype"], :name => "index_inet_object_metas_on_objecttype"
  add_index "inet_object_metas", ["version"], :name => "index_inet_object_metas_on_version"

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

  add_index "iptables_firewall_metas", ["dpt"], :name => "iptables_firewall_metas_dpt_index"
  add_index "iptables_firewall_metas", ["dst"], :name => "iptables_firewall_metas_dst_index"
  add_index "iptables_firewall_metas", ["log_metas_id"], :name => "iptables_firewall_metas_log_metas_id_index"
  add_index "iptables_firewall_metas", ["proto"], :name => "iptables_firewall_metas_proto_index"
  add_index "iptables_firewall_metas", ["pure_metas_id"], :name => "iptables_firewall_metas_pure_metas_id_index"
  add_index "iptables_firewall_metas", ["rule"], :name => "iptables_firewall_metas_rule_index"
  add_index "iptables_firewall_metas", ["spt"], :name => "iptables_firewall_metas_spt_index"
  add_index "iptables_firewall_metas", ["src"], :name => "iptables_firewall_metas_src_index"

  create_table "log_metas", :force => true do |t|
    t.date    "date"
    t.time    "time"
    t.string  "host"
    t.integer "hash_value"
    t.integer "syslogd_metas_id"
    t.integer "pure_metas_id"
    t.integer "file_metas_id"
  end

  add_index "log_metas", ["date"], :name => "log_metas_date_index"
  add_index "log_metas", ["file_metas_id"], :name => "log_metas_file_metas_id_index"
  add_index "log_metas", ["hash_value"], :name => "log_metas_hash_value_index"
  add_index "log_metas", ["host"], :name => "log_metas_host_index"
  add_index "log_metas", ["pure_metas_id"], :name => "log_metas_pure_metas_id_index"
  add_index "log_metas", ["syslogd_metas_id"], :name => "log_metas_syslogd_metas_id_index"
  add_index "log_metas", ["time"], :name => "index_log_metas_on_time"

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

  add_index "metas", ["meta_id"], :name => "metas_meta_id_index"
  add_index "metas", ["meta_type_name"], :name => "metas_meta_type_name_index"
  add_index "metas", ["parent_id"], :name => "metas_parent_id_index"

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

  add_index "nagios_metas", ["affected_host"], :name => "nagios_metas_affected_host_index"
  add_index "nagios_metas", ["log_metas_id"], :name => "nagios_metas_log_metas_id_index"
  add_index "nagios_metas", ["msg_type"], :name => "nagios_metas_msg_type_index"
  add_index "nagios_metas", ["probed_by_host"], :name => "nagios_metas_probed_by_host_index"
  add_index "nagios_metas", ["pure_metas_id"], :name => "nagios_metas_pure_metas_id_index"
  add_index "nagios_metas", ["service"], :name => "nagios_metas_service_index"
  add_index "nagios_metas", ["status"], :name => "nagios_metas_status_index"

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

  add_index "ovpn_base_metas", ["cert"], :name => "ovpn_base_metas_cert_index"
  add_index "ovpn_base_metas", ["client_ip"], :name => "ovpn_base_metas_client_ip_index"
  add_index "ovpn_base_metas", ["client_port"], :name => "ovpn_base_metas_client_port_index"
  add_index "ovpn_base_metas", ["log_metas_id"], :name => "ovpn_base_metas_log_metas_id_index"
  add_index "ovpn_base_metas", ["msg_type"], :name => "ovpn_base_metas_msg_type_index"
  add_index "ovpn_base_metas", ["pure_metas_id"], :name => "ovpn_base_metas_pure_metas_id_index"
  add_index "ovpn_base_metas", ["vpn"], :name => "ovpn_base_metas_vpn_index"

  create_table "postfix_detail_metas", :force => true do |t|
    t.string  "orig_to",            :limit => 50
    t.string  "relay_host",         :limit => 50
    t.string  "relay_ip",           :limit => 50
    t.float   "delay"
    t.integer "size"
    t.integer "nrcpt"
    t.string  "status",             :limit => 20
    t.string  "result_text",        :limit => 200
    t.integer "postfix_metas_id"
    t.integer "relay_port"
    t.float   "delay_before_qmgr"
    t.float   "delay_in_qmgr"
    t.float   "delay_conn_setup"
    t.float   "delay_transmission"
    t.string  "dsn",                :limit => 10
    t.string  "result",             :limit => 20
    t.string  "result_mail_id",     :limit => 10
  end

  add_index "postfix_detail_metas", ["delay"], :name => "altered_postfix_detail_metas_delay_index"
  add_index "postfix_detail_metas", ["postfix_metas_id"], :name => "altered_postfix_detail_metas_postfix_metas_id_index"
  add_index "postfix_detail_metas", ["relay_host"], :name => "altered_postfix_detail_metas_relay_host_index"
  add_index "postfix_detail_metas", ["relay_ip"], :name => "altered_postfix_detail_metas_relay_ip_index"
  add_index "postfix_detail_metas", ["status"], :name => "altered_postfix_detail_metas_status_index"

  create_table "postfix_metas", :force => true do |t|
    t.string  "program",          :limit => 10
    t.integer "process_id"
    t.string  "mail_message_id",  :limit => 15
    t.string  "action",           :limit => 40
    t.string  "host",             :limit => 50
    t.string  "ip",               :limit => 50
    t.integer "pure_metas_id"
    t.integer "log_metas_id"
    t.string  "email_local_part", :limit => 50
    t.string  "message_id",       :limit => 50
    t.string  "email_domain",     :limit => 50
  end

  add_index "postfix_metas", ["action"], :name => "altered_postfix_metas_action_index"
  add_index "postfix_metas", ["email_domain"], :name => "index_postfix_metas_on_email_domain"
  add_index "postfix_metas", ["email_local_part"], :name => "index_postfix_metas_on_email_local_part"
  add_index "postfix_metas", ["host"], :name => "altered_postfix_metas_host_index"
  add_index "postfix_metas", ["ip"], :name => "altered_postfix_metas_ip_index"
  add_index "postfix_metas", ["log_metas_id"], :name => "altered_postfix_metas_log_metas_id_index"
  add_index "postfix_metas", ["mail_message_id"], :name => "altered_postfix_metas_mail_message_id_index"
  add_index "postfix_metas", ["message_id"], :name => "index_postfix_metas_on_message_id"
  add_index "postfix_metas", ["program"], :name => "altered_postfix_metas_program_index"
  add_index "postfix_metas", ["pure_metas_id"], :name => "altered_postfix_metas_pure_metas_id_index"

  create_table "pure_metas", :force => true do |t|
    t.integer "file_metas_id"
    t.integer "compression_metas_id"
  end

  add_index "pure_metas", ["compression_metas_id"], :name => "index_pure_metas_on_compression_metas_id"
  add_index "pure_metas", ["file_metas_id"], :name => "pure_metas_file_metas_id_index"

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

  create_table "squid_metas", :force => true do |t|
    t.integer "process_id"
    t.integer "seconds_since_epoch"
    t.integer "subsecond_time"
    t.integer "response_time_milliseconds"
    t.string  "client_source_ip",           :limit => 40
    t.string  "request_status",             :limit => 30
    t.integer "http_status_code"
    t.integer "reply_size"
    t.string  "request_method",             :limit => 10
    t.text    "request_url"
    t.string  "user_name",                  :limit => 40
    t.string  "hierarchy_status",           :limit => 30
    t.string  "server_ip",                  :limit => 50
    t.string  "mime_type",                  :limit => 60
    t.string  "request_protocol",           :limit => 10
    t.string  "request_host",               :limit => 50
    t.integer "pure_metas_id"
    t.integer "log_metas_id"
    t.string  "protocol_version",           :limit => 5
    t.string  "client_fqdn",                :limit => 50
    t.text    "referer"
    t.string  "user_indent",                :limit => 40
    t.string  "user_agent",                 :limit => 40
    t.string  "user_auth",                  :limit => 40
    t.string  "user_acl",                   :limit => 40
    t.text    "acl_log"
  end

  add_index "squid_metas", ["client_fqdn"], :name => "new_client_fqdn_index"
  add_index "squid_metas", ["client_source_ip"], :name => "index_squid_metas_on_client_source_ip"
  add_index "squid_metas", ["hierarchy_status"], :name => "index_squid_metas_on_hierarchy_status"
  add_index "squid_metas", ["http_status_code"], :name => "index_squid_metas_on_http_status_code"
  add_index "squid_metas", ["log_metas_id"], :name => "index_squid_metas_on_log_metas_id"
  add_index "squid_metas", ["mime_type"], :name => "index_squid_metas_on_mime_type"
  add_index "squid_metas", ["process_id"], :name => "index_squid_metas_on_process_id"
  add_index "squid_metas", ["protocol_version"], :name => "index_squid_metas_on_protocol_version"
  add_index "squid_metas", ["pure_metas_id"], :name => "index_squid_metas_on_pure_metas_id"
  add_index "squid_metas", ["reply_size"], :name => "index_squid_metas_on_reply_size"
  add_index "squid_metas", ["request_host"], :name => "index_squid_metas_on_request_host"
  add_index "squid_metas", ["request_method"], :name => "index_squid_metas_on_request_method"
  add_index "squid_metas", ["request_protocol"], :name => "index_squid_metas_on_request_protocol"
  add_index "squid_metas", ["request_status"], :name => "index_squid_metas_on_request_status"
  add_index "squid_metas", ["response_time_milliseconds"], :name => "index_squid_metas_on_response_time_milliseconds"
  add_index "squid_metas", ["server_ip"], :name => "index_squid_metas_on_client_fqdn"
  add_index "squid_metas", ["user_acl"], :name => "index_squid_metas_on_user_acl"
  add_index "squid_metas", ["user_agent"], :name => "index_squid_metas_on_user_agent"
  add_index "squid_metas", ["user_auth"], :name => "index_squid_metas_on_user_auth"
  add_index "squid_metas", ["user_indent"], :name => "index_squid_metas_on_user_indent"
  add_index "squid_metas", ["user_name"], :name => "index_squid_metas_on_user_name"

  create_table "squid_request_header_metas", :force => true do |t|
    t.string  "authorization",       :limit => 50
    t.string  "cache_control",       :limit => 50
    t.string  "from",                :limit => 50
    t.string  "host",                :limit => 50
    t.string  "if_modified_since",   :limit => 50
    t.string  "if_unmodified_since", :limit => 50
    t.string  "pragma",              :limit => 50
    t.string  "proxy_authorization", :limit => 50
    t.integer "squid_metas_id"
  end

  add_index "squid_request_header_metas", ["authorization"], :name => "index_squid_request_header_metas_on_authorization"
  add_index "squid_request_header_metas", ["from"], :name => "index_squid_request_header_metas_on_from"
  add_index "squid_request_header_metas", ["host"], :name => "index_squid_request_header_metas_on_host"
  add_index "squid_request_header_metas", ["squid_metas_id"], :name => "index_squid_request_header_metas_on_squid_metas_id"

  create_table "squid_response_header_metas", :force => true do |t|
    t.string   "server",             :limit => 50
    t.string   "content_md5",        :limit => 50
    t.string   "age",                :limit => 50
    t.string   "cache_control",      :limit => 50
    t.string   "content_encoding",   :limit => 50
    t.string   "content_language",   :limit => 50
    t.date     "date"
    t.datetime "last_modified"
    t.string   "location",           :limit => 50
    t.string   "pragma",             :limit => 50
    t.string   "proxy_authenticate", :limit => 50
    t.string   "via",                :limit => 50
    t.string   "www_authenticate",   :limit => 50
    t.integer  "squid_metas_id"
  end

  add_index "squid_response_header_metas", ["age"], :name => "index_squid_response_header_metas_on_age"
  add_index "squid_response_header_metas", ["content_encoding"], :name => "index_squid_response_header_metas_on_content_encoding"
  add_index "squid_response_header_metas", ["content_language"], :name => "index_squid_response_header_metas_on_content_language"
  add_index "squid_response_header_metas", ["date"], :name => "index_squid_response_header_metas_on_date"
  add_index "squid_response_header_metas", ["server"], :name => "index_squid_response_header_metas_on_server"
  add_index "squid_response_header_metas", ["squid_metas_id"], :name => "index_squid_response_header_metas_on_squid_metas_id"

  create_table "syslogd_metas", :force => true do |t|
    t.string  "ip",                 :limit => 40
    t.string  "facility",           :limit => 10
    t.string  "priority",           :limit => 10
    t.string  "level",              :limit => 10
    t.string  "tag",                :limit => 10
    t.integer "program"
    t.integer "source_db_metas_id"
    t.integer "archive_metas_id"
    t.integer "queue_id"
  end

  add_index "syslogd_metas", ["archive_metas_id"], :name => "syslogd_metas_archive_metas_id_index"
  add_index "syslogd_metas", ["ip"], :name => "syslogd_metas_ip_index"
  add_index "syslogd_metas", ["program"], :name => "syslogd_metas_program_index"
  add_index "syslogd_metas", ["queue_id"], :name => "index_syslogd_metas_on_queue_id"
  add_index "syslogd_metas", ["source_db_metas_id"], :name => "syslogd_metas_source_db_metas_id_index"

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
  add_index "syslogd_small_base_metas", ["hash_value"], :name => "syslogd_small_base_metas_hash_value_index"
  add_index "syslogd_small_base_metas", ["ip"], :name => "syslogd_small_base_metas_ip_index"
  add_index "syslogd_small_base_metas", ["level"], :name => "syslogd_small_base_metas_level_index"
  add_index "syslogd_small_base_metas", ["log_metas_id"], :name => "syslogd_small_base_metas_log_metas_id_index"
  add_index "syslogd_small_base_metas", ["pure_metas_id"], :name => "syslogd_small_base_metas_pure_metas_id_index"

  create_table "test_metas", :force => true do |t|
    t.string  "message"
    t.integer "pure_metas_id"
    t.integer "log_metas_id"
  end

  add_index "test_metas", ["log_metas_id"], :name => "test_metas_log_metas_id_index"
  add_index "test_metas", ["pure_metas_id"], :name => "test_metas_pure_metas_id_index"

  create_table "ulogd_nfct_metas", :force => true do |t|
    t.integer "process_id"
    t.string  "event",          :limit => 16
    t.string  "orig_saddr",     :limit => 50
    t.string  "orig_daddr",     :limit => 50
    t.string  "orig_protocol",  :limit => 10
    t.integer "orig_sport"
    t.integer "orig_dport"
    t.integer "orig_pktlen"
    t.integer "orig_pktcount"
    t.string  "reply_saddr",    :limit => 50
    t.string  "reply_daddr",    :limit => 50
    t.string  "reply_protocol", :limit => 10
    t.integer "reply_sport"
    t.integer "reply_dport"
    t.integer "reply_pktlen"
    t.integer "reply_pktcount"
    t.integer "icmp_code"
    t.integer "icmp_type"
    t.integer "log_metas_id"
    t.integer "pure_metas_id"
  end

  add_index "ulogd_nfct_metas", ["event"], :name => "index_ulogd_nfct_metas_on_event"
  add_index "ulogd_nfct_metas", ["icmp_code"], :name => "index_ulogd_nfct_metas_on_icmp_code"
  add_index "ulogd_nfct_metas", ["icmp_type"], :name => "index_ulogd_nfct_metas_on_icmp_type"
  add_index "ulogd_nfct_metas", ["log_metas_id"], :name => "index_ulogd_nfct_metas_on_log_metas_id"
  add_index "ulogd_nfct_metas", ["orig_daddr"], :name => "index_ulogd_nfct_metas_on_orig_daddr"
  add_index "ulogd_nfct_metas", ["orig_dport"], :name => "index_ulogd_nfct_metas_on_orig_dport"
  add_index "ulogd_nfct_metas", ["orig_pktcount"], :name => "index_ulogd_nfct_metas_on_orig_pktcount"
  add_index "ulogd_nfct_metas", ["orig_protocol"], :name => "index_ulogd_nfct_metas_on_orig_protocol"
  add_index "ulogd_nfct_metas", ["orig_saddr"], :name => "index_ulogd_nfct_metas_on_orig_saddr"
  add_index "ulogd_nfct_metas", ["orig_sport"], :name => "index_ulogd_nfct_metas_on_orig_sport"
  add_index "ulogd_nfct_metas", ["reply_daddr"], :name => "index_ulogd_nfct_metas_on_reply_daddr"
  add_index "ulogd_nfct_metas", ["reply_dport"], :name => "index_ulogd_nfct_metas_on_reply_dport"
  add_index "ulogd_nfct_metas", ["reply_pktcount"], :name => "index_ulogd_nfct_metas_on_reply_pktcount"
  add_index "ulogd_nfct_metas", ["reply_pktlen"], :name => "index_ulogd_nfct_metas_on_reply_pktlen"
  add_index "ulogd_nfct_metas", ["reply_protocol"], :name => "index_ulogd_nfct_metas_on_reply_protocol"
  add_index "ulogd_nfct_metas", ["reply_saddr"], :name => "index_ulogd_nfct_metas_on_reply_saddr"
  add_index "ulogd_nfct_metas", ["reply_sport"], :name => "index_ulogd_nfct_metas_on_reply_sport"

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

  add_index "windows_event_metas", ["category"], :name => "windows_event_metas_category_index"
  add_index "windows_event_metas", ["computer"], :name => "windows_event_metas_computer_index"
  add_index "windows_event_metas", ["date"], :name => "windows_event_metas_date_index"
  add_index "windows_event_metas", ["event_type"], :name => "windows_event_metas_event_type_index"
  add_index "windows_event_metas", ["facility"], :name => "windows_event_metas_facility_index"
  add_index "windows_event_metas", ["level"], :name => "windows_event_metas_message_level_index"
  add_index "windows_event_metas", ["log_metas_id"], :name => "windows_event_metas_log_metasid_index"
  add_index "windows_event_metas", ["log_name"], :name => "windows_event_metas_log_name_index"
  add_index "windows_event_metas", ["pure_metas_id"], :name => "windows_event_metas_pure_metas_id_index"
  add_index "windows_event_metas", ["source"], :name => "windows_event_metas_source_index"
  add_index "windows_event_metas", ["user"], :name => "windows_event_metas_user_index"

end
