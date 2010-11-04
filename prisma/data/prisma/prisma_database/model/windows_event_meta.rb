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

  # references:
  #  http://support.microsoft.com/kb/308427: How to view and manage event logs in Event Viewer in Windows XP
  #  http://community.netscape.com/n/pfx/forum.aspx?tsn=3&nav=messages&webtag=ws-winprohelp&tid=191184&redirCnt=1: Msg # 191184.3

  class WindowsEventMeta < ActiveRecord::Base
    
    description "Meta base information for windows event logs."
    sources ["PureMeta", "LogMeta"]
    
    preseed_expression /^(Master MSWinEventLog|Replika MSWinEventLog)/

    def WindowsEventMeta.convert_to_unicode(s)
      while s =~ /377777777(\d\d)/
	s.sub!("377777777#{$1}", eval("\"\\303\\2#{$1}\""))
      end
      return s
    end

    def WindowsEventMeta.convert_to_wincode(s)
      ret = ""
      two_byte = false
      s.each_byte {|b|
	if two_byte and b.to_s(8) =~ /2(\d\d)/ then	  
	  ret += "377777777#{$1}"
	else
	  if b.to_s(8) == "303"
	    two_byte = true
	  else
	    ret += eval "\"\\#{b.to_s(8)}\""
	  end
	end
      }

      return ret
    end

    def WindowsEventMeta.create_meta( source_meta, message)
      $log.debug("WIN Got message: #{message}")
      unless message.msg =~ self.preseed_expression
	$log.warn("Cannot create windows meta out of: #{message.msg}")
	return nil
      end
      
      splited = message.msg.split("\00011")
      unless splited.length == 15
	$log.info{"Windows message has not 15 parts separated by \\00011 trying \\t."}
	splited = message.msg.split("\t")
      end

      unless splited.length == 15
	$log.info{"Windows message has not 15 parts separated by \\00011 trying to separate by at least doublspace."}
	splited = message.msg.split("  ").map {|m| m.strip}.reject {|m| m == ""}
      end

      unless splited.length == 15
	$log.warn{"Cannot split message by \\00011 nor by tab nor by double spacing algorithm. giving up. (#{splited.inspect})"}
	return nil
      end

      splited.each_with_index{|m,i| splited[i] = convert_to_unicode(m)}
      
      datetime = DateTime.strptime(splited[4],"%a %b %d %T %Y")
      
      WindowsEventMeta.new.prisma_initialize(source_meta,
			   { :log_name => splited[0], # ["Master MSWinEventLog", "Replika MSWinEventLog"]
			     :field1 => splited[1], # ["1"]
			     :event_type => splited[2], # ["Application", "System", "Security"]
			     :field3 => splited[3], #  num
			     :date => datetime,:time => Time.parse(datetime.to_s),  #4 date Wed Aug 08 10:07:16 2007
			     :event_id => splited[5], # ["1011", "15224", "15223", "452", "453", "40960", "146", "11166", "6013", "17101", "528", "680", "538", "15221", "7", "7035"]
			     :source => splited[6], # ["ACESERVER6.1", "SDSERV_PROGRESS", "LSASRV", "DnsApi", "EventLog", "ACECLIENT", "Security", "Norton AntiVirus", "Service Control Manager"]
			     :user => splited[7], # ["Unknown User", "SDesk", "SYSTEM"]
			     :category => splited[8], # ["N/A", "User"]
			     :level => splited[9], ## ["Information", "Warning", "Success Audit"]
			     :computer => splited[10], # ["MSP43", "MSP44"]
			     :facility => splited[11], #11 ["Devices", "Shell", "Printers", "None", "Disk", "Logon/Logoff", "Account Logon"]
			     :data => splited[12], #12 trace_binary
			     :field14=>  splited[14], #14 num
			     
			     :message => splited[13] #13 message
			   })
    end
  end

