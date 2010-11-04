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

  class CiscoFirewallConnectionMeta < ActiveRecord::Base

    description "Cisco firewall connection messages."
    sources ["CiscoBaseMeta", "LogMeta"]

    def self.may_have_messages?; false; end

    def self.expressions
      ret = []
      # Built ICMP connection for faddr 160.63.224.200/512 gaddr 10.73.248.181/0 laddr 10.73.248.181/0
      ret.push({ :regex => /^(Teardown|Built|Built inbound|Built outbound) (ICMP) connection for faddr ([^\/]*)\/(\d*) gaddr ([^\/]*)\/(\d*) laddr ([^\/]*)\/(\d*) *$/,
		 :fields => [:msg, :connection_type, :foreign_ip, :foreign_port, :global_to_ip, :global_to_port, :local_ip, :local_port]})

      # Teardown UDP connection 139434 for kopo_outside:160.63.221.143/137 to inside:160.63.221.255/137 duration 0:02:01 bytes 150
      ret.push({ :regex => /^(Teardown) (TCP|UDP) connection (\d*) for ([^:]*):([^\/]*)\/(\d*) to ([^:]*):([^\/]*)\/(\d*) duration (\d*:\d*:\d*) bytes (\d*) *$/,
		 :fields => [:msg, :connection_type, :connection_id, :foreign_name, :foreign_ip, :foreign_port, :local_name, :local_ip, :local_port, :duration, :bytes]})


      # Teardown TCP connection 139480 for inside:160.63.226.11/636 to NP Identity Ifc:10.73.248.181/1027 duration 0:00:00 bytes 583 TCP Reset-O 
      ret.push({ :regex => /^(Teardown) (TCP|UDP) connection (\d*) for ([^:]*):([^\/]*)\/(\d*) to ([^:]*):([^\/]*)\/(\d*) duration (\d*:\d*:\d*) bytes (\d*)( .*)? *$/,
		 :fields => [:msg, :connection_type, :connection_id, :foreign_name, :foreign_ip, :foreign_port, :local_name, :local_ip, :local_port, :duration, :bytes, :reason]})


      # Built inbound UDP connection 139462 for management:10.73.134.134/1097 (10.73.134.134/1097) to NP Identity Ifc:10.73.248.81/161 (10.73.248.81/161)
      # Built inbound UDP connection 320459 for kopo_outside:160.63.221.163/138 (160.63.221.163/138) to inside:160.63.221.255/138 (160.63.221.255/138) (3mre)
      ret.push({ :regex => /^(Built inbound|Built outbound) (TCP|UDP) connection (\d*) for ([^:]*):([^\/]*)\/(\d*) \(([^\/]*)\/(\d*)\) to ([^:]*):([^\/]*)\/(\d*) \(([^\/]*)\/(\d*)\)( \(([^\)]*)\))? *$/,
		 :fields => [:msg, :connection_type, :connection_id, :foreign_name, :foreign_ip, :foreign_port, :global_from_ip, :global_from_port, :local_name, :local_ip, :local_port, :global_to_ip, :global_to_port, nil, :user]})

      # UDP access permitted from 10.73.134.134/59153 to inside:10.73.249.17/snmp   
      # UDP access permitted from 10.73.134.142/40207 to inside:10.73.248.181/snmp
      ret.push({ :regex => /^(UDP) (access permitted|request discarded) from ([^\/]*)\/([^ ]*) to ([^:]*):([^\/]*)\/([^ ]*) *$/,
		 :fields => [:connection_type, :msg, :foreign_ip, :foreign_port, :local_name, :local_ip, :local_port]})

      # LU allocate connection failed 
      ret.push({ :regex => /^(LU allocate connection failed) *$/,
		 :fields => [:msg]})
      
      return ret
    end
  end

