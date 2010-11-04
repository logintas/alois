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

class InetHeaderMeta < ActiveRecord::Base

  description "Header of inet messages."
  sources ["PureMeta", "LogMeta"]
  
  preseed_expression /^\d\d\d\d-\d\d-\d\d \d\d\:\d\d\:\d\d\,\d\d\d\;/
  
  def self.expressions
    ret = []
    
    ret.push({ :regex => /^(\d\d\d\d-\d\d-\d\d) (\d\d\:\d\d\:\d\d)\,(\d\d\d)\;([^\;]*)\;([^\;]*)\;([^\;]*)\;([^\;]*)\;([^\;]*)\;(.*)$/,
	       :fields => [:date, :time, :milliseconds, :severity, :system_id, :msg_id, :user_id, :eventtype, :message]})
    
    return ret
  end
 
  def remove_semicolons(arr)
    arr.each_with_index {|str,i|
      str = str.strip
      if str and str[0..0] == "\"" and str[-1..-1] == "\""
	str = str[1..-2]
      end
      arr[i] = str
    }   
    return arr
  end
    
  def self.before_filter(msg)
    WindowsEventMeta.convert_to_unicode(msg)
  end

  def self.invers_before_filter(msg)
    msg.class == String ? WindowsEventMeta.convert_to_wincode(msg) : msg      
  end
  
  def after_filling_values(values)
    msg = values[:message]
    $log.info{"msg_id is #{self.msg_id}"}
    case self.msg_id
    when "applAuth"      
      # client_ip
      # server_ip
      # session_id
      throw "Could not parse msg #{msg.inspect} in '#{self.msg_id}'" unless 
	msg =~ /^(.*)\;(\"[^\"]*\"|[^\;]*)\;(\"[^\"]*\"|[^\;]*)\;(\"[^\"]*\"|[^\;]*)$/
      self.client_ip, self.server_ip, self.session_id = remove_semicolons([$2,$3,$4])
      $log.debug{"client_ip = '#{self.client_ip}' server_ip = #{self.server_ip} session_id = #{self.session_id}"}    
    when "applDataAccess"
      # object_old_values (1024)
      # object_new_values (1024)
      throw "Could not parse msg #{msg.inspect} in '#{self.msg_id}'" unless
	msg =~ /^(.*)\;(\"[^\"]*\"|[^\;]*)\;(\"[^\"]*\"|[^\;]*)$/
      self.text1, self.text2 = remove_semicolons([$2,$3])
      $log.debug{"text1 = '#{self.text1}' text2 = '#{self.text3}'"}
    when "applLookup"
      # query (1024)
      # hit_number :integer
      # num_object_hits :integer
      throw "Could not parse msg #{msg.inspect} in '#{self.msg_id}'" unless 
	msg =~ /^(.*)\;(\"[^\"]*\"|[^\;]*)\;(\"[^\"]*\"|[^\;]*)\;(\"[^\"]*\"|[^\;]*)$/
      self.text1, self.hit_number, self.num_object_hits = remove_semicolons([$2,$3,$4])
      $log.debug{"text1 = '#{self.text1}' hit_number = '#{self.hit_number}' num_object_hits = '#{self.num_object_hts}'"}
    when "applPerm"
      # perm_old (1024)
      # perm_new (1024)
      throw "Could not parse msg #{msg.inspect} in '#{self.msg_id}'" unless
	msg =~ /^(.*)\;(\"[^\"]*\"|[^\;]*)\;(\"[^\"]*\"|[^\;]*)\"$/
      self.text1, self.text2 = remove_semicolons([$2,$3])
      $log.debug{"text1 = '#{self.text1}' text2 = '#{self.text2}'"}
    when "applEvent"
      # position (1024)
      # msg (1024)
      throw "Could not parse msg #{msg.inspect} in '#{self.msg_id}'" unless
	msg =~ /^(.*)\;(\"[^\"]*\"|[^\;]*)\;(\"[^\"]*\"|[^\;]*)$/
      self.text1, self.text2 = remove_semicolons([$2,$3])
      $log.debug{"text1 = '#{self.text1}' text2 = '#{self.text2}'"}
    when "applInterface"
      # msg (1024)
      throw "Could not parse msg #{msg.inspect} in '#{self.msg_id}'" unless
	msg =~ /^(.*)\;(\"[^\"]*\"|[^\;]*)$/
      self.text1 = remove_semicolons([$2])[0]
      $log.debug{"text1 = '#{self.text1}'"}
    when "applMonitor"
      # msg (1024)
      throw "Could not parse msg #{msg.inspect} in '#{self.msg_id}'" unless
	msg =~ /^(.*)\;(\"[^\"]*\"|[^\;]*)$/
      self.text1 = remove_semicolons([$2])[0]
      $log.debug{"text1 = '#{self.text1}'"}      
    else
      throw "Unknown message id '#{msg_id}'."
    end
    $log.debug{"Rest of the message is: #{$1}"}
    values[:message] = $1
  end

end
