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

  class NagiosMeta < ActiveRecord::Base

    description "Nagios Logs"
    sources ["PureMeta", "LogMeta"]
    
    preseed_expression /^nagios:/

    def self.may_have_messages?; false; end

    def self.expressions
      ret = []
      ##nagios: SERVICE ALERT: host1.example.com;http-www.example.com;CRITICAL;SOFT;1;CRITICAL - Socket timeout after 15 seconds [probed by nagios.exapmle.com]
      ret.push({ :regex => /^nagios: ([A-Z ]*): ([^;]*);([^;]*);([^;]*);([^;]*);([^;]*);([^\[]*)(\[probed by ([^\]]*)\])?( *)$/,
        :fields => [:msg_type, :affected_host, :service, :status, :unknown_1, :unknown_2,
        :output, nil, :probed_by_host, nil ]})

      # nagios: SERVICE ALERT: host1.example.com;http-www.example.com;OK;SOFT;2;HTTP OK HTTP/1.0 200 OK - 0.239 second response time  
      # nagios: EXTERNAL COMMAND: PROCESS_SERVICE_CHECK_RESULT;nagios.example.com;nagios;0;Nagios OK - Nagios seems to be running on nagios.example.com  
      ret.push({ :regex => /^nagios: (EXTERNAL COMMAND: PROCESS_SERVICE_CHECK_RESULT);([^;]*);([^;]*);([^;]*);([^\[]*)(\[probed by ([^\]]*)\])?( *)$/,
        :fields => [:msg_type, :affected_host, :service, :unknown_2,
        :output, nil, :probed_by_host, nil]})

      return ret
    end

  end
