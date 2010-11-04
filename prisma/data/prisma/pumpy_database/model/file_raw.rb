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

  class FileRaw < ActiveRecord::Base

    description "File raw record on pumpy."
    
    def self.default_waiting_time
      60 * 15
    end
    
    def self.default_count; 1; end

    def self.create(file, options={})
      options[:extname] ||= File.extname(file)
      if options.is_a?(Hash)
	options = options.map {|key,val| "#{key}=#{val}"}.join(",")
      end

      m = self.new
      m.dirname = File.dirname(file)
      m.basename = File.basename(file)
      m.ftype = File.ftype(file)
      m.size = File.size(file)
      m.mtime = File.mtime(file)
      m.atime = File.atime(file)
      m.ctime = File.ctime(file)
      m.options = options
      #      m.umask = f.umask
      #      m.uid = File.uid(file)
      #      m.gid = File.gid(file)
      File.open(file, "rb") do |io_r|
	m.msg = io_r.read(m.size)
      end
      m.save
      return m
    end

    def self.may_contain_dublettes
      true
    end
  end
