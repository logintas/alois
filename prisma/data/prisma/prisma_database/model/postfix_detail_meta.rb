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

  class PostfixDetailMeta < ActiveRecord::Base

    description "Parsed postfix detail messages."
    sources ["PostfixMeta"]

    def self.may_have_messages?; false; end

    def self.expressions
      ret = []

      ret.push({ :regex => /^size=(\d*), nrcpt=(\d*) \(([^\)]*)\)( *)$/,
        :fields => [:size, :nrcpt, :status, nil]})

      #to=<test@mail.example.com>, orig_to=<postmaster@example.com>, relay=local, delay=0, status=sent (delivered to command: /usr/bin/procmail -a "$EXTENSION" DEFAULT=$HOME/Maildir/ MAILDIR=$HOME/Maildir)
      #to=<test@mail.example.com>, orig_to=<admin@example.com>, relay=mail2.example.com[192.168.123.123], delay=1, status=sent (250 Ok: queued as 12AF7B902B8)

      #to=<archive@mail.logintas.ch>, orig_to=<archive_mail@mail.logintas.ch>, relay=local, delay=0.41, delays=0.24/0/0/0.17, dsn=2.0.0, status=sent (delivered to command: /usr/bin/procmail -a "$EXTENSION" DEFAULT=$HOME/Maildir/ MAILDIR=$HOME/Maildir)
      ret.push({ :regex => /(orig_to=<([^>]*)>, )?relay=([^\[,]*)(\[([^\]]*)\])?(\:(\d+))?, delay=(\d+\.?\d*), (delays=(\d+\.?\d*)\/(\d+\.?\d*)\/(\d+\.?\d*)\/(\d+\.?\d*), )?(dsn=([^\,]*), )?status=([^ ]*) \((.* ([^ ]+) as ([A-F0-9]{11}))\) *$/,
        :fields => [nil, :orig_to, :relay_host, nil, :relay_ip, nil, :relay_port, :delay,nil,:delay_before_qmgr, :delay_in_qmgr ,:delay_conn_setup, :delay_transmission, nil, :dsn, :status, :result_text, :result, :result_mail_id]})

      # this is the same as above without the last .. as .. regexp (result_text only)
      ret.push({ :regex => /(orig_to=<([^>]*)>, )?relay=([^\[,]*)(\[([^\]]*)\])?(\:(\d+))?, delay=(\d+\.?\d*), (delays=(\d+\.?\d*)\/(\d+\.?\d*)\/(\d+\.?\d*)\/(\d+\.?\d*), )?(dsn=([^\,]*), )?status=([^ ]*) \((.*)\) *$/,
        :fields => [nil, :orig_to, :relay_host, nil,:relay_ip, nil,:relay_port, :delay,nil,:delay_before_qmgr, :delay_in_qmgr ,:delay_conn_setup, :delay_transmission, nil, :dsn, :status, :result_text]})

# to=<archive_mail@mail.logintas.ch>, relay=127.0.0.1[127.0.0.1]:10024, delay=5, delays=0.03/0/0/4.9, dsn=2.6.0, status=sent (250 2.6.0 Ok, id=31764-06, from MTA([127.0.0.1]:10025): 250 2.0.0 Ok: queued as C1C991F0FA9)=> nil


#      ret.push({ :regex => /^to=<([^>]*)>, (orig_to=<([^>]*)>, )?relay=([^\[,]*)(\[[^\]]*\])?, delay=(\d+\.?\d*), (delays=(\d+\.?\d*)\/(\d+\.?\d*)\/(\d+\.?\d*)\/(\d+\.?\d*), )?(dsn=([^\,]*, )?status=([^ ]*) \(.*\)$/,
#        :fields => [:to, nil, :orig_to, :relay_host, :relay_ip, :delay,nil,:delay_before_qmgr, :delay_in_qmgr ,:delay_conn_setup, :delay_transmission, nil, :dsn, :status, :result_text]})


      #to=<archive_mail@mail.logintas.ch>, relay=127.0.0.1[127.0.0.1]:10024, delay=5.7, delays=0.1/0/0/5.6, dsn=2.6.0, status=sent (250 2.6.0 Ok, id=15500-09, from MTA([127.0.0.1]:10025): 250 2.0.0 Ok: queued as 76B191F10AA)


# (delivered to command: /usr/bin/procmail -a "$EXTENSION" DEFAULT=$HOME/Maildir/ MAILDIR=$HOME/Maildir)
# (250 2.6.0 Ok, id=15500-09, from MTA([127.0.0.1]:10025): 250 2.0.0 Ok: queued as 76B191F10AA)
      return ret
    end

  end
