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

class RemoveOrMovePrismaTables < ActiveRecord::Migration

  PRISMA_TABLES = ["ace_passcode_metas","amavis_metas","apache_file_metas",
                   "apache_log_metas","apache_metas","archive_metas","cisco_base_metas",
                   "cisco_firewall_connection_metas","cisco_firewall_metas","cisco_metas",
                   "cisco_session_metas","compression_metas","cron_metas","fetchmail_metas",
                   "file_metas","inet_header_metas","inet_object_metas","iptables_firewall_metas",
                   "log_metas","messages","metas","nagios_metas","nonyms","ovpn_base_metas",
                   "postfix_detail_metas","postfix_metas","pure_metas","source_db_metas",
                   "squid_metas","squid_request_header_metas","squid_response_header_metas",
                   "syslogd_metas","syslogd_small_base_metas","test_metas","ulogd_nfct_metas",
                   "windows_event_metas "]

  def self.up
    # Moving can only be done if the alois and future prisma
    # databases are on the same server
    alois_spec = ActiveRecord::Base.configurations[RAILS_ENV]
    prisma_spec = ActiveRecord::Base.configurations["prisma"]

    print "Alois connection: #{alois_spec.inspect}\n"
    print "Prisma connection: #{prisma_spec.inspect}\n"

    move_possible = true
    
    unless alois_spec["adapter"] == "mysql" and
        prisma_spec["adapter"] == "mysql"
      move_possible = false
      print "Not both adapters are mysql\n"
    end
      
    unless alois_spec["host"] == prisma_spec["host"]
      move_possible = false
      print "Not both databases are on the same host\n"
    end

    if move_possible and $ui.question("\nMove prisma tables on #{alois_spec["host"]} from #{alois_spec["database"]} to #{prisma_spec["database"]} is possible.\nDo you want to do that?")

      raise "Alois database not given" if alois_spec["database"].blank?
      raise "Prisma database not given" if prisma_spec["database"].blank?

      PRISMA_TABLES.each {|table|
        execute "RENAME TABLE #{alois_spec["database"]}.#{table} TO #{prisma_spec["database"]}.#{table}"
      }
    else      
      unless $ui.question("\nMoving prisma tables to another database is not possible or not desired.\n" +
                          "So prisma tables should be removed now from alois database.\n" +
                          "THIS IS YOUR LAST CHANCE TO ABORT\n" +
                          "\n" +
                          "CAN I REMOVE PRISMA TABLES FROM ALOIS DATABASE NOW?", :default => false)
        raise "Abort by user"

      end
      tbls = tables
      PRISMA_TABLES.each {|table|        
        drop_table(table) if tbls.include?(table)
      }
    end

    View.find(:all).each {|v| execute "DROP VIEW IF EXISTS view_#{v.id}"}
    print "\n\n/!\\Please execute in console: View.find(:all).each {|v| begin v.create_view rescue p $! end }; nil\n\n"   
  end

  def self.down
return
    alois_spec = ActiveRecord::Base.configurations[RAILS_ENV]
    prisma_spec = ActiveRecord::Base.configurations["prisma"]

    print "Alois connection: #{alois_spec.inspect}\n"
    print "Prisma connection: #{prisma_spec.inspect}\n"

    raise "Aborted by user" unless $ui.question("Try to downgrade -> move prisma tables into alois db again\n\nABORT IF YOU DO NOT KNOW WHAT THIS MEANS!!\n\nDo that now?")

    PRISMA_TABLES.each {|table|
      execute "RENAME TABLE #{prisma_spec["database"]}.#{table} TO #{alois_spec["database"]}.#{table}"
    }
  end
end
