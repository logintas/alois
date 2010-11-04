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

  class PureMeta < ActiveRecord::Base

    description  "Meta record for a single message line"
    sources ["FileMeta","CompressionMeta"]
    

    def self.create_meta( meta_message, message)
      return nil if CompressionMeta.applyable?(meta_message,message)

      case meta_message
      when FileMeta, CompressionMeta
	$log.debug{"Filetype of file meta is '#{meta_message.filetype}'."}
	if meta_message.filetype == "log" or meta_message.filetype == "syslog" then
	  
	  if meta_message == FileMeta
	    # check if the message has correct size
	    throw "Message length '#{message.msg.length}' not equal to original file size '#{meta_message.size}'!" if
	      message.msg.length != meta_message.size
	  end
	  for line in message.msg
	    $log.debug("Pure Meta created:'#{line}'") if $log.debug?
	    pure = PureMeta.new.prisma_initialize(meta_message, {:message=>line})
	    pure.transform
	  end      
	end
 	meta_message.message = nil
	return nil
      end
      return nil
    end
  end

