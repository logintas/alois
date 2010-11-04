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

  class OvpnBaseMeta < ActiveRecord::Base

    description "OpenVPN Logs"
    sources ["PureMeta", "LogMeta"]
    preseed_expression /^ovpn-/

    def self.may_have_messages?; false; end

    def self.expressions
      ret = []

      ret.push({ :regex => /^ovpn-([^\[]*)\[([^\]]*)\]: ((\d{1,3}\.){3}\d{1,3}):(\d*) (([A-Z ]*):)?(.*)$/,
        :fields => [:vpn,:process_id,:client_ip,nil,:client_port,nil,:msg_type,:msg]})
      ret.push({ :regex => /^ovpn-([^\[]*)\[([^\]]*)\]: (([^ ]*)_([^\/_]*))\/((\d{1,3}\.){3}\d{1,3}):(\d*) (([A-Z ]*):)?(.*)$/,
        :fields => [:vpn,:process_id,:cert,nil,:client,:client_ip,nil,:client_port,nil,:msg_type,:msg]})
      ret.push({ :regex => /^ovpn-([^\[]*)\[([^\]]*)\]: (([A-Z ]*):)?(.*)$/,
        :fields => [:vpn,:process_id,nil,:msg_type,:msg]})

      return ret
    end

  end
