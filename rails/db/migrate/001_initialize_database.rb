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
    
    create_table "amavis_metas" do |t|
      t.column "process_id", :integer
      t.column "amavis_id", :string, :limit => 20
      t.column "action", :string, :limit => 20
      t.column "status", :string, :limit => 20
      t.column "from_field", :string, :limit => 50
      t.column "to_field", :string
      t.column "message_id", :string, :limit => 50
      t.column "hits", :string, :limit => 10
      t.column "process_time", :integer
      t.column "ip", :string, :limit => 50
      t.column "signature", :string, :limit => 50
      t.column "quarantine", :string, :limit => 50
      t.column "pure_metas_id", :integer
      t.column "log_metas_id", :integer
    end
    
    add_index "amavis_metas", ["action"], :name => "amavis_metas_action_index"
    add_index "amavis_metas", ["status"], :name => "amavis_metas_status_index"
    add_index "amavis_metas", ["from_field"], :name => "amavis_metas_from_field_index"
    add_index "amavis_metas", ["message_id"], :name => "amavis_metas_message_id_index"
    add_index "amavis_metas", ["ip"], :name => "amavis_metas_ip_index"
    add_index "amavis_metas", ["signature"], :name => "amavis_metas_signature_index"
    add_index "amavis_metas", ["pure_metas_id"], :name => "amavis_metas_pure_metas_id_index"
    add_index "amavis_metas", ["log_metas_id"], :name => "amavis_metas_log_metas_id_index"
    
    create_table "apache_file_metas" do |t|
      t.column "virtual_host", :string, :limit => 100
      t.column "file_metas_id", :integer
    end
    add_index "apache_file_metas", ["file_metas_id"], :name => "apache_file_metas_file_metas_id_index"
    
    create_table "apache_log_metas" do |t|
      t.column "forensic_id", :string, :limit => 30
      t.column "serve_time", :integer
      t.column "host", :string, :limit => 50
    end

    create_table "apache_metas" do |t|
      t.column "remote_host", :string, :limit => 40
      t.column "remote_logname", :string, :limit => 20
      t.column "remote_user", :string, :limit => 20
      t.column "time", :time
      t.column "date", :date
      t.column "first_line", :string, :limit => 512
      t.column "status", :integer
      t.column "bytes", :integer
      t.column "referer", :string, :limit => 40
      t.column "useragent", :string, :limit => 40
      t.column "log_metas_id", :integer
      t.column "pure_metas_id", :integer
    end

    add_index "apache_metas", ["remote_host"], :name => "apache_metas_remote_host_index"
    add_index "apache_metas", ["remote_user"], :name => "apache_metas_remote_user_index"
    add_index "apache_metas", ["status"], :name => "apache_metas_status_index"
    add_index "apache_metas", ["useragent"], :name => "apache_metas_useragent_index"
    add_index "apache_metas", ["first_line"], :name => "apache_metas_first_line_index"
    add_index "apache_metas", ["log_metas_id"], :name => "apache_metas_log_metas_id_index"
    add_index "apache_metas", ["pure_metas_id"], :name => "apache_metas_pure_metas_id_index"

    create_table "archive_metas" do |t|
      t.column "filename", :string
      t.column "current", :integer
      t.column "total", :integer
      t.column "todo", :integer
      t.column "finished", :boolean, :default => false
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
    end

    create_table "cisco_base_metas" do |t|
      t.column "ip", :string, :limit => 40
      t.column "message_type", :string, :limit => 10
      t.column "severity", :integer
      t.column "message_number", :integer
      t.column "log_metas_id", :integer
      t.column "syslogd_small_base_metas_id", :integer
    end

    add_index "cisco_base_metas", ["ip"], :name => "cisco_base_metas_ip_index"
    add_index "cisco_base_metas", ["message_type"], :name => "cisco_base_metas_message_type_index"
    add_index "cisco_base_metas", ["severity"], :name => "cisco_base_metas_severity_index"
    add_index "cisco_base_metas", ["log_metas_id"], :name => "cisco_base_metas_log_metas_id_index"
    add_index "cisco_base_metas", ["syslogd_small_base_metas_id"], :name => "cisco_base_metas_syslogd_small_base_metas_id_index"

    create_table "cisco_firewall_connection_metas" do |t|
      t.column "msg", :string, :limit => 30
      t.column "reason", :string, :limit => 30
      t.column "connection_id", :integer
      t.column "connection_type", :string, :limit => 10
      t.column "foreign_name", :string, :limit => 30
      t.column "foreign_ip", :string, :limit => 40
      t.column "foreign_port", :string, :limit => 10
      t.column "local_name", :string, :limit => 30
      t.column "local_ip", :string, :limit => 40
      t.column "local_port", :string, :limit => 10
      t.column "global_to_ip", :string, :limit => 40
      t.column "global_to_port", :string, :limit => 10
      t.column "global_from_ip", :string, :limit => 40
      t.column "global_from_port", :string, :limit => 10
      t.column "duration", :time
      t.column "bytes", :integer
      t.column "cisco_base_metas_id", :integer
      t.column "log_metas_id", :integer
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

    create_table "cisco_firewall_metas" do |t|
      t.column "msg", :string, :limit => 100
      t.column "source", :string, :limit => 40
      t.column "source_port", :string, :limit => 10
      t.column "destination", :string, :limit => 40
      t.column "destination_port", :string, :limit => 10
      t.column "interface", :string, :limit => 20
      t.column "cisco_base_metas_id", :integer
    end

    add_index "cisco_firewall_metas", ["source"], :name => "cisco_firewall_metas_source_index"
    add_index "cisco_firewall_metas", ["source_port"], :name => "cisco_firewall_metas_source_port_index"
    add_index "cisco_firewall_metas", ["destination"], :name => "cisco_firewall_metas_destination_index"
    add_index "cisco_firewall_metas", ["destination_port"], :name => "cisco_firewall_metas_destination_port_index"
    add_index "cisco_firewall_metas", ["interface"], :name => "cisco_firewall_metas_interface_index"
    add_index "cisco_firewall_metas", ["cisco_base_metas_id"], :name => "cisco_firewall_metas_cisco_base_metas_id_index"


    create_table "cisco_metas" do |t|
      t.column "msg", :string, :limit => 100
      t.column "server", :string, :limit => 40
      t.column "server_port", :string, :limit => 10
      t.column "name", :string, :limit => 40
      t.column "ip", :string, :limit => 40
      t.column "port", :string, :limit => 10
      t.column "user", :string, :limit => 20
      t.column "group_name", :string, :limit => 20
      t.column "reason", :string, :limit => 100
      t.column "cisco_base_metas_id", :integer
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

    create_table "cron_metas" do |t|
      t.column "process_id", :integer
      t.column "user", :string, :limit => 20
      t.column "uid", :integer
      t.column "program", :string, :limit => 20
      t.column "action", :string, :limit => 20
      t.column "command", :string
      t.column "pure_metas_id", :integer
      t.column "log_metas_id", :integer
    end

    add_index "cron_metas", ["user"], :name => "cron_metas_user_index"
    add_index "cron_metas", ["uid"], :name => "cron_metas_uid_index"
    add_index "cron_metas", ["program"], :name => "cron_metas_program_index"
    add_index "cron_metas", ["action"], :name => "cron_metas_action_index"
    add_index "cron_metas", ["pure_metas_id"], :name => "cron_metas_pure_metas_id_index"
    add_index "cron_metas", ["log_metas_id"], :name => "cron_metas_log_metas_id_index"

    create_table "fetchmail_metas" do |t|
      t.column "process_id", :integer
      t.column "program", :string, :limit => 20
      t.column "action", :string, :limit => 200
      t.column "pure_metas_id", :integer
      t.column "log_metas_id", :integer
    end

    add_index "fetchmail_metas", ["program"], :name => "fetchmail_metas_program_index"
    add_index "fetchmail_metas", ["action"], :name => "fetchmail_metas_action_index"
    add_index "fetchmail_metas", ["pure_metas_id"], :name => "fetchmail_metas_pure_metas_id_index"
    add_index "fetchmail_metas", ["log_metas_id"], :name => "fetchmail_metas_log_metas_id_index"

    create_table "file_metas" do |t|
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
      t.column "source_db_metas_id", :integer
      t.column "archive_metas_id", :integer
    end
    add_index "file_metas", ["source_db_metas_id"], :name => "file_metas_source_db_metas_id_index"
    add_index "file_metas", ["archive_metas_id"], :name => "file_metas_archive_metas_id_index"

    create_table "filters" do |t|
      t.column "name", :string
      t.column "order_by", :string
      t.column "yaml_declaration", :text
      t.column "description", :text
    end

    create_table "iptables_firewall_metas" do |t|
      t.column "rule", :string, :limit => 10
      t.column "src", :string, :limit => 20
      t.column "spt", :string, :limit => 10
      t.column "dst", :string, :limit => 20
      t.column "dpt", :string, :limit => 10
      t.column "custom", :string, :limit => 20
      t.column "in", :string, :limit => 10
      t.column "out", :string, :limit => 10
      t.column "physin", :string, :limit => 10
      t.column "physout", :string, :limit => 10
      t.column "len", :integer
      t.column "tos", :string, :limit => 10
      t.column "prec", :string, :limit => 10
      t.column "ttl", :integer
      t.column "identifier", :integer
      t.column "proto", :string, :limit => 10
      t.column "additional", :string, :limit => 20
      t.column "pure_metas_id", :integer
      t.column "log_metas_id", :integer
    end

    add_index "iptables_firewall_metas", ["rule"], :name => "iptables_firewall_metas_rule_index"
    add_index "iptables_firewall_metas", ["src"], :name => "iptables_firewall_metas_src_index"
    add_index "iptables_firewall_metas", ["spt"], :name => "iptables_firewall_metas_spt_index"
    add_index "iptables_firewall_metas", ["dst"], :name => "iptables_firewall_metas_dst_index"
    add_index "iptables_firewall_metas", ["dpt"], :name => "iptables_firewall_metas_dpt_index"
    add_index "iptables_firewall_metas", ["proto"], :name => "iptables_firewall_metas_proto_index"
    add_index "iptables_firewall_metas", ["log_metas_id"], :name => "iptables_firewall_metas_log_metas_id_index"
    add_index "iptables_firewall_metas", ["pure_metas_id"], :name => "iptables_firewall_metas_pure_metas_id_index"

    create_table "log_metas" do |t|
      t.column "date", :date
      t.column "time", :time
      t.column "host", :string
      t.column "hash_value", :integer
      t.column "syslogd_metas_id", :integer
      t.column "pure_metas_id", :integer
      t.column "file_metas_id", :integer
    end
    add_index "log_metas", ["syslogd_metas_id"], :name => "log_metas_syslogd_metas_id_index"
    add_index "log_metas", ["pure_metas_id"], :name => "log_metas_pure_metas_id_index"
    add_index "log_metas", ["file_metas_id"], :name => "log_metas_file_metas_id_index"

    add_index "log_metas", ["date"], :name => "log_metas_date_index"
    add_index "log_metas", ["host"], :name => "log_metas_host_index"
    add_index "log_metas", ["hash_value"], :name => "log_metas_hash_value_index"

    create_table "messages" do |t|
      t.column "meta_id", :integer
      t.column "msg", :binary
      t.column "meta_type_name", :string, :limit => 100
    end

    add_index "messages", ["meta_id"], :name => "messages_meta_id_index"
    add_index "messages", ["meta_type_name"], :name => "messages_meta_type_name_index"

    create_table "metas" do |t|
      t.column "parent_id", :integer
      t.column "meta_type_name", :string, :limit => 100
      t.column "meta_id", :integer
    end

    add_index "metas", ["parent_id"], :name => "metas_parent_id_index"
    add_index "metas", ["meta_type_name"], :name => "metas_meta_type_name_index"
    add_index "metas", ["meta_id"], :name => "metas_meta_id_index"

    create_table "nagios_metas" do |t|
      t.column "msg_type", :string, :limit => 50
      t.column "probed_by_host", :string, :limit => 50
      t.column "affected_host", :string, :limit => 50
      t.column "service", :string, :limit => 20
      t.column "status", :string, :limit => 20
      t.column "unknown_1", :string, :limit => 20
      t.column "unknown_2", :integer
      t.column "output", :string
      t.column "pure_metas_id", :integer
      t.column "log_metas_id", :integer
    end

    add_index "nagios_metas", ["msg_type"], :name => "nagios_metas_msg_type_index"
    add_index "nagios_metas", ["probed_by_host"], :name => "nagios_metas_probed_by_host_index"
    add_index "nagios_metas", ["affected_host"], :name => "nagios_metas_affected_host_index"
    add_index "nagios_metas", ["service"], :name => "nagios_metas_service_index"
    add_index "nagios_metas", ["status"], :name => "nagios_metas_status_index"
    add_index "nagios_metas", ["pure_metas_id"], :name => "nagios_metas_pure_metas_id_index"
    add_index "nagios_metas", ["log_metas_id"], :name => "nagios_metas_log_metas_id_index"


    create_table "nonyms" do |t|
      t.column "real_name", :string, :limit => 20
    end

    add_index "nonyms", ["real_name"], :name => "nonyms_real_name_index"

    create_table "ovpn_base_metas" do |t|
      t.column "vpn", :string, :limit => 20
      t.column "process_id", :integer
      t.column "client_ip", :string, :limit => 50
      t.column "client_port", :integer
      t.column "cert", :string, :limit => 50
      t.column "msg_type", :string, :limit => 50
      t.column "msg", :string
      t.column "client", :string, :limit => 20
      t.column "pure_metas_id", :integer
      t.column "log_metas_id", :integer
    end

    add_index "ovpn_base_metas", ["vpn"], :name => "ovpn_base_metas_vpn_index"
    add_index "ovpn_base_metas", ["client_ip"], :name => "ovpn_base_metas_client_ip_index"
    add_index "ovpn_base_metas", ["client_port"], :name => "ovpn_base_metas_client_port_index"
    add_index "ovpn_base_metas", ["cert"], :name => "ovpn_base_metas_cert_index"
    add_index "ovpn_base_metas", ["msg_type"], :name => "ovpn_base_metas_msg_type_index"
    add_index "ovpn_base_metas", ["pure_metas_id"], :name => "ovpn_base_metas_pure_metas_id_index"
    add_index "ovpn_base_metas", ["log_metas_id"], :name => "ovpn_base_metas_log_metas_id_index"

    create_table "postfix_detail_metas" do |t|
      t.column "message_id", :string, :limit => 50
      t.column "from", :string, :limit => 50
      t.column "to", :string, :limit => 50
      t.column "orig_to", :string, :limit => 50
      t.column "relay_host", :string, :limit => 50
      t.column "relay_ip", :string, :limit => 50
      t.column "delay", :integer
      t.column "size", :integer
      t.column "nrcpt", :integer
      t.column "status", :string, :limit => 20
      t.column "command", :string, :limit => 200
      t.column "postfix_metas_id", :integer
    end

    add_index "postfix_detail_metas", ["relay_host"], :name => "postfix_detail_metas_relay_host_index"
    add_index "postfix_detail_metas", ["relay_ip"], :name => "postfix_detail_metas_relay_ip_index"
    add_index "postfix_detail_metas", ["delay"], :name => "postfix_detail_metas_delay_index"
    add_index "postfix_detail_metas", ["status"], :name => "postfix_detail_metas_status_index"
    add_index "postfix_detail_metas", ["postfix_metas_id"], :name => "postfix_detail_metas_postfix_metas_id_index"

    create_table "postfix_metas" do |t|
      t.column "program", :string, :limit => 10
      t.column "process_id", :integer
      t.column "mail_message_id", :string, :limit => 10
      t.column "action", :string, :limit => 40
      t.column "host", :string, :limit => 50
      t.column "ip", :string, :limit => 50
      t.column "pure_metas_id", :integer
      t.column "log_metas_id", :integer
    end

    add_index "postfix_metas", ["program"], :name => "postfix_metas_program_index"
    add_index "postfix_metas", ["action"], :name => "postfix_metas_action_index"
    add_index "postfix_metas", ["mail_message_id"], :name => "postfix_metas_mail_message_id_index"
    add_index "postfix_metas", ["host"], :name => "postfix_metas_host_index"
    add_index "postfix_metas", ["ip"], :name => "postfix_metas_ip_index"
    add_index "postfix_metas", ["pure_metas_id"], :name => "postfix_metas_pure_metas_id_index"
    add_index "postfix_metas", ["log_metas_id"], :name => "postfix_metas_log_metas_id_index"

    create_table "pure_metas" do |t|
      t.column "file_metas_id", :integer
    end
    add_index "pure_metas", ["file_metas_id"], :name => "pure_metas_file_metas_id_index"

    create_table "sentinels" do |t|
      t.column "name", :string
      t.column "description", :text
      t.column "view_id", :integer
      t.column "threshold", :integer
      t.column "send_ossim", :boolean
      t.column "send_mail", :boolean
      t.column "mail_to", :text
      t.column "external_program", :text
      t.column "cron_interval", :text
      t.column "enabled", :boolean
    end

    create_table "source_db_metas" do |t|
      t.column "process_type", :string, :limit => 10
      t.column "start", :integer
      t.column "current", :integer
      t.column "total", :integer
      t.column "todo", :integer
      t.column "count", :integer
      t.column "raw_class_name", :string, :limit => 20
      t.column "execute_once", :boolean
      t.column "waiting_time", :integer
      t.column "finished", :boolean, :default => false
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
    end

    create_table "syslogd_metas" do |t|
      t.column "ip", :string, :limit => 40
      t.column "facility", :string, :limit => 10
      t.column "priority", :string, :limit => 10
      t.column "level", :string, :limit => 10
      t.column "tag", :string, :limit => 10
      t.column "program", :integer, :limit => 15
      t.column "source_db_metas_id", :integer
      t.column "archive_metas_id", :integer
    end

    add_index "syslogd_metas", ["ip"], :name => "syslogd_metas_ip_index"
    add_index "syslogd_metas", ["program"], :name => "syslogd_metas_program_index"
    add_index "syslogd_metas", ["source_db_metas_id"], :name => "syslogd_metas_source_db_metas_id_index"
    add_index "syslogd_metas", ["archive_metas_id"], :name => "syslogd_metas_archive_metas_id_index"
    
    create_table "syslogd_small_base_metas" do |t|
      t.column "date", :date
      t.column "time", :time
      t.column "level", :string, :limit => 10
      t.column "ip", :string, :limit => 40
      t.column "hash_value", :integer
      t.column "pure_metas_id", :integer
      t.column "log_metas_id", :integer
    end

    add_index "syslogd_small_base_metas", ["date"], :name => "syslogd_small_base_metas_date_index"
    add_index "syslogd_small_base_metas", ["level"], :name => "syslogd_small_base_metas_level_index"
    add_index "syslogd_small_base_metas", ["ip"], :name => "syslogd_small_base_metas_ip_index"
    add_index "syslogd_small_base_metas", ["hash_value"], :name => "syslogd_small_base_metas_hash_value_index"
    add_index "syslogd_small_base_metas", ["pure_metas_id"], :name => "syslogd_small_base_metas_pure_metas_id_index"
    add_index "syslogd_small_base_metas", ["log_metas_id"], :name => "syslogd_small_base_metas_log_metas_id_index"

    create_table "test_metas" do |t|
      t.column "message", :string
      t.column "pure_metas_id", :integer
      t.column "log_metas_id", :integer
    end
    add_index "test_metas", ["log_metas_id"], :name => "test_metas_log_metas_id_index"
    add_index "test_metas", ["pure_metas_id"], :name => "test_metas_pure_metas_id_index"

    create_table "views" do |t|
      t.column "name", :string
      t.column "sql_declaration", :text
      t.column "additional_fields", :text
      t.column "date_column_name", :text
      t.column "description", :text
    end
    
  end

  def self.down
    raise IrreversibleMigration
  end
  
end







