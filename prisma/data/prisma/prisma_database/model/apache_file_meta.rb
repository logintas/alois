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

  class ApacheFileMeta < ActiveRecord::Base

    description "Apache Logfile Infos"
    sources ["FileMeta"]
    
    def initialize( source_meta, virtual_host, message )
      super(source_meta)
      self.virtual_host = virtual_host
      self.save
      for line in message.msg
	pure = PureMeta.new.prisma_initialize(self, {:message=>line})
	pure.transform
      end
    end
    
    def self.create_meta( meta_message, message )
      if meta_message.class == FileMeta then
	if meta_message.filetype == "apache" then
	  virtual_host = meta_message.read_option("virtual_host")
	  if virtual_host == nil then
	    $log.error("Option virtual_host not defined for apache-file.") if $log.error?
	    return nil
	  else
	    return self.new.prisma_initialize(meta_message, virtual_host, message)
	  end
	end
      end
    end
  end
