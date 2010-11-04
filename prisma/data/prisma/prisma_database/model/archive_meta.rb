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

  class ArchiveMeta < ActiveRecord::Base

    description "Metadatas for database sources (pumpy raw table imports)."
    
    def self.each_message_of_file(filename)
      for line in open(filename)
	msg = nil
	begin	 
	  # leave this for security (evaluating string)
	  throw "Leading and/or tailing \" not found in line #{self.current}!" unless line =~ /^".*\"$/
	  throw "Suspicious line found at line #{self.current} (unquoted \" found)!" if line =~ /\".*[^\\]\".*\"/
	  msg = YAML.parse(eval(line)).transform
	rescue 
	 $log.error "Error getting archive record \##{self.current}. (#{$!.message})" if $log.error?
	end
	yield msg if msg
	exit(0) if $terminate
      end
    end
    
    def initialize( filename ) 
      super(nil)
      self.filename = filename
      self.current = 0
      self.total = open(filename).readlines.length
      self.todo = self.total
      self.save
    end
    
    def messages
      raise LocalJumpError unless block_given?
      Archivator.messages(filename) {|m|
	yield m
	self.current = self.current + 1
	self.todo = self.total - self.current
	self.save
	exit(0) if $terminate	
      }
    end

  end
