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

class PostfixMoveAddressToPostfixMeta < ActiveRecord::Migration

  FIELDS_TO_COMPACT = ["from","to","message_id"]

  def self.convert_email(m)
    p = m.parent
    raise "Parent not found for #{m.class}.#{m.id}" unless p

    found = []
    email = nil
    field = nil
    FIELDS_TO_COMPACT.each {|f|
      c = m.send(f)
      c = nil if c == ""
      next unless c
      raise "#{f} defined but parent's action is not #{f} (#{p.action})" if
	p.action.gsub("-","_") != f
      found << f 
      field, email = f, c
    }
    
    case found.length
    when 0
      # there is no field to convert
      return nil
    when 1
      # thats fine
    else
      raise "More than one field found to convert: #{found.inspect}" 
    end
    
    s = email.split("@")
    raise "Email #{s} of #{m.class}.#{m.id} has not two components (split with @ has length #{s.length}" unless
      s.length == 2
    
    if field == "message_id"
      p.message_id = s[0]
    else
      p.email_local_part = s[0]
    end
    p.email_domain = s[1]
    p.save
  end

  def self.up
    unless PostfixMeta.column_names.include?("email_domain")
      add_column "postfix_metas", "email_local_part", :string, :limit => 50
      add_column "postfix_metas", "message_id", :string, :limit => 50
      add_column "postfix_metas", "email_domain", :string, :limit => 50
      add_index "postfix_metas", ["email_local_part"]
      add_index "postfix_metas", ["email_domain"]
      add_index "postfix_metas", ["message_id"]      
    end
    
    PostfixDetailMeta.find(:all).each {|m|
      convert_email(m)
    }
    remove_column "postfix_detail_metas", "from"
    remove_column "postfix_detail_metas", "to"
    remove_column "postfix_detail_metas", "message_id"    
  end
  
  def self.unconvert_email(m)
    p = m.parent
    raise "Parent not found for #{m.class}.#{m.id}" unless p
    
    return nil unless p.action
    return nil unless FIELDS_TO_COMPACT.include?(p.action.gsub("-","_"))
    
    if p.action == "message-id"
      m.send("message_id=","#{p.message_id}@#{p.email_domain}")
    else
      m.send("#{p.action}=","#{p.email_local_part}@#{p.email_domain}")
    end
  end
  
  def self.down
    unless PostfixDetailMeta.column_names.include?("to")
      add_column "postfix_detail_metas", "message_id", :string, :limit => 50
      add_column "postfix_detail_metas", "from", :string, :limit => 50
      add_column "postfix_detail_metas", "to", :string, :limit => 50
      add_index "postfix_detail_metas", ["to"]
      add_index "postfix_detail_metas", ["from"]
      add_index "postfix_detail_metas", ["message_id"]
    end

    PostfixDetailMeta.find(:all).each {|m|
      unconvert_email(m)
    }

    remove_column "postfix_metas", "email_local_part"
    remove_column "postfix_metas", "email_domain"
    remove_column "postfix_metas", "message_id"
  end
end
