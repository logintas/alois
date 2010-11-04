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

  class FileMeta < ActiveRecord::Base

    description "Metadatas for files."
    sources ["SourceDbMeta","ArchiveMeta"]

    def filename
      return File.join(self.dirname,self.basename)
    end    
    
    def read_option(name)
      $log.debug{"Splitting #{name}"}
      return nil if options == nil
      for option in options.split(",")
	(option_name,option_value) = option.split("=")
	return option_value if option_name == name 
      end     
      return nil
    end

    def filetype
      return (self.read_option("type") or self.read_option("filetype"))
    end

    def self.create_meta(meta_record, message)
      if message.class == FileRaw then
	return self.new.prisma_initialize(meta_record,{:dirname => message.dirname,
			  :basename => message.basename,
			  :ftype => message.ftype, 
			  :size =>  message.size, 
			  :mtime => message.mtime,
			  :atime => message.atime,
			  :ctime => message.ctime,
			  :umask => message.umask,
			  :uid => message.uid,
			  :gid => message.gid,
			  :options => message.options,
			  :message => message.msg})
      end
      return nil
    end

    def reproducable?
      true
    end
  end
