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

  class UlogdNfctMeta < ActiveRecord::Base
    
    description "Ulogd Netfilter Connection Tracking Logs"
    sources ["PureMeta", "LogMeta"]
    
    preseed_expression /^ulogd\[/

    def self.may_have_messages?; false; end
    
    def self.expressions
      ret = []

      # ICMP:
      # ulogd[9441]: [NEW]     ORIG: SRC=192.168.130.1 DST=192.168.130.33 PROTO=ICMP TYPE=0 CODE=8
      #                              PKTS=1 BYTES=84 , REPLY: SRC=192.168.130.33 DST=192.168.130.1
      #                              PROTO=ICMP TYPE=0 CODE=8 PKTS=0 BYTES=0
      # ulogd[9441]: [DESTROY] ORIG: SRC=192.168.130.1 DST=192.168.130.60 PROTO=ICMP TYPE=0 CODE=8
      #                              PKTS=1 BYTES=84 , REPLY: SRC=192.168.130.60 DST=192.168.130.1
      #                              PROTO=ICMP TYPE=0 CODE=8 PKTS=0 BYTES=0
      ret.push({ :regex =>  /^ulogd\[([^\]]*)\]:\s+\[([^\]]+)\]\s+ORIG:\s+SRC=(\S+)\s+DST=(\S+)\s+PROTO=(ICMP)\s+TYPE=(\d+)\s+CODE=(\d+)\s+PKTS=(\d+)\s+BYTES=(\d+)\s+,\s+REPLY:\s+SRC=(\S+)\s+DST=(\S+)\s+PROTO=(ICMP)\s+TYPE=(\d+)\s+CODE=(\d+)\s+PKTS=(\d+)\s+BYTES=(\d+)/,
        :fields => [:process_id, :event, :orig_saddr, :orig_daddr, :orig_protocol, :icmp_type, :icmp_code, :orig_pktcount, :orig_pktlen, :reply_saddr, :reply_daddr, :reply_protocol, nil, nil, :reply_pktcount, :reply_pktlen]})
      
      # UDP:
      # ulogd[9441]: [NEW]     ORIG: SRC=192.168.61.182 DST=192.168.61.130 PROTO=UDP SPT=123 DPT=123
      #                              PKTS=1 BYTES=76 , REPLY: SRC=192.168.61.130 DST=192.168.61.182
      #                              PROTO=UDP SPT=123 DPT=123 PKTS=0 BYTES=0
      # ulogd[9441]: [DESTROY] ORIG: SRC=192.168.130.60 DST=192.168.61.54 PROTO=UDP SPT=48875 DPT=53
      #                              PKTS=8 BYTES=580 , REPLY: SRC=192.168.61.54 DST=192.168.130.60
      #                              PROTO=UDP SPT=53 DPT=48875 PKTS=8 BYTES=1515
      #
      # TCP:
      # ulogd[9441]: [NEW]     ORIG: SRC=192.168.130.64 DST=192.168.61.58 PROTO=TCP SPT=4506 DPT=8080
      #                              PKTS=1 BYTES=60 , REPLY: SRC=192.168.61.58 DST=192.168.130.64
      #                              PROTO=TCP SPT=8080 DPT=4506 PKTS=0 BYTES=0
      # ulogd[9441]: [DESTROY] ORIG: SRC=192.168.130.60 DST=192.168.61.58 PROTO=TCP SPT=37971 DPT=8080
      #                              PKTS=5 BYTES=1377 , REPLY: SRC=192.168.61.58 DST=192.168.130.60
      #                              PROTO=TCP SPT=8080 DPT=37971 PKTS=5 BYTES=966
      ret.push({ :regex => /^ulogd\[([^\]]*)\]:\s+\[([^\]]+)\]\s+ORIG:\s+SRC=(\S+)\s+DST=(\S+)\s+PROTO=(\S+)\s+SPT=(\d+)\s+DPT=(\d+)\s+PKTS=(\d+)\s+BYTES=(\d+)\s+,\s+REPLY:\s+SRC=(\S+)\s+DST=(\S+)\s+PROTO=(\S+)\s+SPT=(\d+)\s+DPT=(\d+)\s+PKTS=(\d+)\s+BYTES=(\d+)/,
		 :fields => [:process_id, :event, :orig_saddr, :orig_daddr, :orig_protocol, :orig_sport, :orig_dport, :orig_pktcount, :orig_pktlen, :reply_saddr, :reply_daddr, :reply_protocol, :reply_sport, :reply_dport, :reply_pktcount, :reply_pktlen]})
      
      return ret
    end
    
  end
