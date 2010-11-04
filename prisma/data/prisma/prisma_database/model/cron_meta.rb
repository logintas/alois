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

  class CronMeta < ActiveRecord::Base

    description "Cron Logs"
    sources ["PureMeta", "LogMeta"]
    
    preseed_expression /^CRON\[|^\/USR\/SBIN\/CRON\[/

    def self.may_have_messages?; false; end

    def self.expressions
      ret = []

      # CRON[30589]: (pam_unix) session closed for user root
      ret.push({ :regex => /^CRON\[([^\]]*)\]: \(([^)]*)\) (.*) for user ([^ ]*)( *)$/,
        :fields => [:process_id,:program,:action,:user,nil]})
      # CRON[4614]: (pam_unix) session opened for user mail by (uid=0)     
      ret.push({ :regex => /^CRON\[([^\]]*)\]: \(([^)]*)\) (.*) for user ([^ ]*) by \(uid=([^)]*)\)( *)$/,
        :fields => [:process_id,:program,:action,:user,:uid,nil]})

      # /USR/SBIN/CRON[4615]: (mail) CMD (  if [ -x /usr/lib/exim/exim3 -a -f /etc/exim/exim.conf ]; then /usr/lib/exim/exim3 -q ; fi) 
      ret.push({ :regex => /^\/USR\/SBIN\/CRON\[([^\]]*)\]: \(([^)]*)\) (CMD) \(([^)]*)\)( *)$/,
        :fields => [:process_id,:user,:action,:command,nil]})

      return ret
    end
  end
