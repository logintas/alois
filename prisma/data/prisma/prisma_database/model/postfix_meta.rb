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

  class PostfixMeta < ActiveRecord::Base

    description "Postfix Logs"
    sources ["PureMeta", "LogMeta"]
    
    preseed_expression /^postfix\//

    def self.expressions
      ret = []

      ret.push({ :regex => /^postfix\/([^\[]*)\[([^\]]*)\]: (connect|disconnect) from ([^\[]*)\[([^\]]*)\]( *)$/,
        :fields => [:program, :process_id, :action, :host, :ip, nil]})

      ret.push({ :regex => /^postfix\/([^\[]*)\[([^\]]*)\]: ([A-Z0-9]*): (removed)( *)$/,
        :fields => [:program, :process_id, :mail_message_id, :action, nil]})

      ret.push({ :regex => /^postfix\/([^\[]*)\[([^\]]*)\]: ((warning):.*)$/,
        :fields => [:program, :process_id, :message, :action]})

      ret.push({ :regex => /^postfix\/([^\[]*)\[([^\]]*)\]: ([A-Z0-9]*): (client)=([^\[]*)\[([^\]]*)\]( *)$/,
        :fields => [:program, :process_id, :mail_message_id, :action, :host, :ip, nil]})

      ret.push({ :regex => /^postfix\/([^\[]*)\[([^\]]*)\]: ([A-Z0-9]*): (from|to)=<([^@]+)@([^\>]+)>, (.*)$/,
        :fields => [:program, :process_id, :mail_message_id,:action, :email_local_part, :email_domain, :message]})

      ret.push({ :regex => /^postfix\/([^\[]*)\[([^\]]*)\]: ([A-Z0-9]*): (message-id)=<([^@]+)@([^\>]+)>$/,
        :fields => [:program, :process_id, :mail_message_id, :action, :message_id, :email_domain]})
      return ret
    end

  end
