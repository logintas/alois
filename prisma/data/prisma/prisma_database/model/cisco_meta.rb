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

  class CiscoMeta < ActiveRecord::Base

    description "Cisco parsed messages."
    sources ["CiscoBaseMeta"]

    def self.may_have_messages?; false; end

    def self.expressions
      ret = []
      # Starting SSL handshake with client inside:127.0.0.1/9999 for TLSv1 session.
      # Starting SSL handshake with client outside:127.0.0.1/9999 for TLSv1 session.
      # Device completed SSL handshake with client outside:127.0.0.1/9999
      # Device completed SSL handshake with server inside:127.0.0.1/9999
      # Device completed SSL handshake with client outside:127.0.0.1/9999
      # Device completed SSL handshake with client outside:127.0.0.1/9999
      # SSL session with server inside:127.0.0.1/9999 terminated.
      # SSL session with client outside:127.0.0.1/9999 terminated.
      # SSL session with client outside:127.0.0.1/9999 terminated.
      #SSL session with client outside:127.0.0.1/9999 terminated.|         

      ret.push({ :regex => /^(.* (server|client) )([^:]*):([^\/]*)\/([^ ]*) ?(.*)$/,
        :fields => [:msg, nil, :name, :ip, :port, :msg]})

      # Group <test-vpn> User <test> IP <127.0.0.1> WebVPN session started.
      # Group <test-vpn> User <test> IP <127.0.0.1> Authentication: successful, Session Type: WebVPN.
      # Group <test-vpn> User <test> IP <127.0.0.1> SVC connection established with compression
      # Group <test-vpn> User <test> IP <127.0.0.1> WebVPN session terminated: User Requested.
      # Group <test-vpn> User <test> IP <127.0.0.1> SVC connection terminated with compression     
      ret.push({ :regex => /^Group <([^>]*?)> User <([^>]*?)> IP <([^>]*?)> (.*)$/, 
        :fields => [:group_name, :user, :ip, :msg]})

      # User priv level changed: Uname: test From: 1 To: 15
      ret.push({ :regex => /^User ([^:]*): Uname: ([^ ]*)( From: [^ ]* To: [^ ]*)$/, 
        :fields => [:msg, :user,:msg]})

      #  User authentication succeeded: Uname: test 
      ret.push({ :regex => /^User ([^:]*): Uname: ([^ ]*)$/, 
        :fields => [:msg, :user]})

      # AAA retrieved default group policy (test-vpn) for user = test
      ret.push({ :regex => /^(AAA .*) \(([^\)]*?)\) for user = ([^ ]*)$/, 
        :fields => [:msg, :group_name, :user]})

      # AAA user authorization Rejected : reason = Attribute not found : server = 127.0.0.1 : user = test
      ret.push({ :regex => /^(AAA .*) : reason = (.*) : server = ([^ ]*) : user = ([^ ]*)$/, 
        :fields => [:msg, :reason, :server, :user]})
      ret.push({ :regex => /^(AAA .*) : server =  ([^ ]*) : user = ([^ ]*)$/, 
        :fields => [:msg, :server, :user]})
      ret.push({ :regex => /^(AAA .*) : user = ([^ ]*)$/, 
        :fields => [:msg, :user]})

      #Group = test-vpn, Username = test, IP = 127.0.0.1, Session disconnected. Session Type: SVC, Duration: 0h:13m:28s, Bytes xmt: 111111, Bytes rcv: 111111, Reason: User Requested|
	ret.push({ :regex => /^Group = (.*), Username = (.*), IP = ([^,]*), (.*), Reason: (.*) *$/, 
		   :fields => [:group_name, :user, :ip, :msg, :reason]})
	ret.push({ :regex => /^Group = (.*), IP = ([^,]*), ([^=]*) *$/, 
		   :fields => [:group_name, :ip, :msg]})
	ret.push({ :regex => /^IP = ([^,]*), (.*with payloads.*) *$/, 
		   :fields => [:ip, :msg]})

      # User 'test' executed the 'terminal pager 0' command.
      ret.push({ :regex => /^User \'([^\']*)\' (executed) the \'([^\']*)\'( command)\.$/,
        :fields => [:user, :msg, :name, :msg]})

      # Login permitted from 127.0.0.1/9999 to mgmt:127.0.0.1/telnet for user "test"|
      ret.push({ :regex => /^(.*) from ([^\/]*)\/([^ ]*) to ([^:]*):([^\/]*)\/([^ ]*) for user \"([^\"]*)\"$/,
        :fields => [:msg, :ip, :port, :name, :server, :server_port,:user]})

      # ASDM session number 0 from 127.0.0.1 started
      # ASDM logging session number 0 from 127.0.0.1 started
      ret.push({ :regex => /^(ASDM.* session number (.*)) from ([^ ]*)( started)$/,
        :fields => [:msg, nil, :ip, :msg]})

      # User 'test' executed cmd: show vpn-sessiondb svc
      # User 'test' executed cmd: show vpn-sessiondb summary
      ret.push({ :regex => /^User \'([^\']*)\' (executed cmd): (.*)$/,
        :fields => [:user, :msg, :name]})

      return ret
    end
  end
