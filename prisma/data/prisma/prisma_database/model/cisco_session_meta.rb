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

  class CiscoSessionMeta < ActiveRecord::Base

    description "Cisco parsed messages."
#    if PrismaDbVersion.database_version > 2
#      sources ["CiscoMeta"] 
#    end

    def self.expressions
      ret = []

      # Session disconnected. Session Type: SVC, Duration: 0h:13m:28s, Bytes xmt: 393829, Bytes rcv: 446476, Reason: User Requested

      ret.push({ :regex => /^Session (disconnected). Session Type: ([^,]*), Duration: ([^,]*), Bytes xmt: ([^,]*), Bytes rcv: ([^,]*), Reason: ([^,]*)$/,
 		 :fields => [:msg, :session_type, :duration, :out_bytes, :in_bytes, :reason]})
      return ret
    end
  end
