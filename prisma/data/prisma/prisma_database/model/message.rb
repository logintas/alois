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

  # Message class for storing unparsed messages
  class Message < ActiveRecord::Base

    description "Messages that are in process or not yet parsable."
    
    #should this be a symbol?
    def self.primary_key
      :id
    end

    # The parent class of this message
    def parent_class
      throw "Unexpected meta_type_name #{meta_type_name}." unless meta_type_name =~ /^Prisma::([A-Za-z]+)$/
      eval($1)
    end
    # Returns parent meta of this message
    def parent; parent_class.find(meta_id); end
    # A message never has submessages, so always nil
    def messages; nil; end
    
    # Creates a new message and sets field according to the parameters. If meta class has
    # not been saved yet (new_record? == true), the meta will be saved to create an id.
    def prisma_initialize(meta, msg, options = {} )
      $log.debug("Creating message with length '#{msg.length}'")
      meta.save_without_validation if meta.new_record?
      self.meta_id = meta.id
      self.meta_type_name = "Prisma::" + meta.class.name
      self.msg = msg
      if options[:fast_association]
	meta.message_fast = self
      else
	# base_mixin.message= expects that
	meta.messages << self
      end
      self
    end

    def to_s
      if msg and msg.length > 1024
	"Message.#{id} <#{msg[0..1023]}...>"
      else
	"Message.#{id} <#{msg}>"
      end
    end

    # Return a hash value for the message
    def get_hash
      msg.hash
    end

    # Returns a sql query for view creation out of UI.
    def join_query(query=nil)
      query = "#{self.class.table_name}" unless query
      p = parent
      if p then
        query = "#{query} LEFT JOIN #{p.class.table_name} ON #{self.class.table_name}.meta_id = #{p.class.table_name}.id AND #{self.class.table_name}.meta_type_name = 'Prisma::#{p.class.name}'"
        query = p.join_query(query)
      end
      return query
    end
    # nothing to join to messages table, always nil
    def self.get_join; return nil; end

  end
