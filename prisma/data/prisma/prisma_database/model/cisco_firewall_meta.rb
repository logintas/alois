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

  class CiscoFirewallMeta < ActiveRecord::Base

    description "Cisco firewall messages."
    sources ["CiscoBaseMeta"]

    def self.may_have_messages?; false; end

    def self.expressions
      ret = []
      # Inbound TCP connection denied from 193.246.92.241/443 to 80.254.180.156/3770 flags RST ACK on interface outside
      # Deny TCP (no connection) from 10.73.11.110/1811 to 10.73.248.81/23 flags RST  on interface management|
      ret.push({ :regex => /^(.* )from ([^\/]*)\/([^ ]*) to ([^\/]*)\/([^ ]*) (.*) +on interface ([^ ]*) *$/,
        :fields => [:msg, :source, :source_port, :destination, :destination_port,:msg, :interface]})

      # Deny IP from 160.63.221.136 to 224.0.0.22, IP options: "Router Alert"| 
      ret.push({ :regex => /^(.* )from ([^ ]*) to ([^,]*), (IP options: \"([^\"]*)\") *$/,
        :fields => [:msg, :source, :destination, :msg, nil]})

      # No route to 239.255.255.250 from 160.63.221.134|
      ret.push({ :regex => /^(No route) to ([^ ]*) from ([^ ]*) *$/,
        :fields => [:msg, :destination, :source]})

      # TCP request discarded from 10.73.11.110/1817 to management:10.73.248.81/23		
      # TCP access permitted from 10.73.11.110/1999 to management:10.73.248.81/telnet
      ret.push({ :regex => /^(TCP .*) from ([^\/]*)\/([^ ]*) to ([^:]*):([^\/]*)\/(.*) *$/,
        :fields => [:msg, :source, :source_port, :interface, :destination, :destination_port]})

      return ret
    end
  end
