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

  class IptablesFirewallMeta < ActiveRecord::Base

    description "Iptables Logs"
    sources ["PureMeta", "LogMeta"]
     
    preseed_expression /^kernel:/
    def self.may_have_messages?; false; end


    def self.expressions
      ret = []

      # kernel: Swl:AllowLPR:2:ACCEPT:IN= OUT=eth0 SRC=127.0.0.1 DST=127.0.0.1 LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=9716 DF PROTO=TCP SPT=60749 DPT=9100 WINDOW=5840 RES=0x00 SYN URGP=0 '
      ret.push({ :regex => /^kernel:(.*):(ACCEPT|DROP|REJECT|DNAT):IN=([^ ]*) OUT=([^ ]*) SRC=([^ ]*) DST=([^ ]*) LEN=([^ ]*) TOS=([^ ]*) PREC=([^ ]*) TTL=([^ ]*) ID=([^ ]*) DF PROTO=([^ ]*) SPT=([^ ]*) DPT=([^ ]*) (.*)$/,
        :fields => [:custom, :rule, :in, :out, :src, :dst,
        :len, :tos, :prec, :ttl, :identifier, :proto, :spt, :dpt, :additional]})

      # kernel: Swl:AllowNetDiag:3:ACCEPT:IN= OUT=eth0 SRC=127.0.0.1 DST=127.0.0.1 LEN=84 TOS=0x00 PREC=0x00 TTL=64 ID=0 DF PROTO=ICMP TYPE=8 CODE=0 ID=34074 SEQ=5
      ret.push({ :regex => /^kernel:(.*):(ACCEPT|DROP|REJECT|DNAT):IN=([^ ]*) OUT=([^ ]*) SRC=([^ ]*) DST=([^ ]*) LEN=([^ ]*) TOS=([^ ]*) PREC=([^ ]*) TTL=([^ ]*) ID=([^ ]*) DF PROTO=([^ ]*) (TYPE=([^ ]*) CODE=([^ ]*) )ID=([^ ]*) (.*)$/,
        :fields => [:custom, :rule, :in, :out, :src, :dst,
        :len, :tos, :prec, :ttl, :identifier, :proto, :additional, nil, nil, :additional, :additional]})

      # kernel: Swl:all2all:REJECT:IN=br0 OUT=br2 PHYSIN=eth0 PHYSOUT=eth2 SRC=127.0.0.1 DST=127.0.0.1 LEN=60 TOS=0x00 PREC=0x00 TTL=62 ID=15783 DF PROTO=TCP SPT=52069 DPT=6667 WINDOW=5840 RES=0x00 SYN URGP=0 
      ret.push({ :regex => /^kernel:(.*):(ACCEPT|DROP|REJECT|DNAT):IN=([^ ]*) OUT=([^ ]*) PHYSIN=([^ ]*) PHYSOUT=([^ ]*) SRC=([^ ]*) DST=([^ ]*) LEN=([^ ]*) TOS=([^ ]*) PREC=([^ ]*) TTL=([^ ]*) ID=([^ ]*) DF PROTO=([^ ]*) SPT=([^ ]*) DPT=([^ ]*) (.*)$/,
        :fields => [:custom, :rule, :in, :out, :physin, :physout, :src, :dst,
        :len, :tos, :prec, :ttl, :identifier, :proto, :spt, :dpt, :additional]})
      #kernel: Swl:all2all:1:REJECT:IN=eth0 OUT= MAC=00:01:03:17:49:8f:00:0a:5e:1e:82:b2:08:00 SRC=127.0.0.1 DST=127.0.0.1 LEN=84 TOS=0x00 PREC=0x00 TTL=62 ID=0 DF PROTO=ICMP TYPE=8 CODE=0 ID=33312 SEQ=1
      ret.push({ :regex => /^kernel:(.*):(ACCEPT|DROP|REJECT|DNAT):IN=([^ ]*) OUT=([^ ]*) MAC=([^ ]*) SRC=([^ ]*) DST=([^ ]*) LEN=([^ ]*) TOS=([^ ]*) PREC=([^ ]*) TTL=([^ ]*) ID=([^ ]*) DF PROTO=([^ ]*) (.*)$/,
        :fields => [:custom, :rule, :in, :out, :additional, :src, :dst,
        :len, :tos, :prec, :ttl, :identifier, :proto, :additional]})

      #kernel: Swl:AllowNetDiag:3:ACCEPT:IN=br5 OUT=eth1 PHYSIN=eth4 SRC=127.0.0.1 DST=127.0.0.1 LEN=84 TOS=0x00 PREC=0x00 TTL=62 ID=0 DF PROTO=ICMP TYPE=8 CODE=0 ID=34074 SEQ=1
      ret.push({ :regex => /^kernel:(.*):(ACCEPT|DROP|REJECT|DNAT):IN=([^ ]*) OUT=([^ ]*) PHYSIN=([^ ]*) SRC=([^ ]*) DST=([^ ]*) LEN=([^ ]*) TOS=([^ ]*) PREC=([^ ]*) TTL=([^ ]*) ID=([^ ]*) DF PROTO=([^ ]*) (.*)$/,
        :fields => [:custom, :rule, :in, :out, :physin, :src, :dst,
        :len, :tos, :prec, :ttl, :identifier, :proto, :additional]})

      #kernel: Swl:AllowDNS:ACCEPT:IN=br0 OUT= PHYSIN=eth1 MAC=00:a0:24:be:8b:0a:00:0a:5e:07:3b:b6:08:00 SRC=127.0.0.1 DST=127.0.0.1 LEN=69 TOS=0x00 PREC=0x00 TTL=63 ID=53465 DF PROTO=UDP SPT=51022 DPT=53 LEN=49
      ret.push({ :regex => /^kernel:(.*):(ACCEPT|DROP|REJECT|DNAT):IN=([^ ]*) OUT=([^ ]*) PHYSIN=([^ ]*) MAC=([^ ]*) SRC=([^ ]*) DST=([^ ]*) LEN=([^ ]*) TOS=([^ ]*) PREC=([^ ]*) TTL=([^ ]*) ID=([^ ]*) DF PROTO=([^ ]*) SPT=([^ ]*) DPT=([^ ]*) (.*)$/,
        :fields => [:custom, :rule, :in, :out, :physin, :additional, :src, :dst,
        :len, :tos, :prec, :ttl, :identifier, :proto, :spt, :dpt, :additional]})

      return ret
    end

  end

