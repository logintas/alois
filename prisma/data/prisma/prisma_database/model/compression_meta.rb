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

# Class for uncompressing files
class CompressionMeta < ActiveRecord::Base
  
  description "Metadatas for files."
  sources ["FileMeta"]

  DECOMPRESSION_COMMANDS = {
    ".bz2" => "bunzip2",
    ".gz" => "gunzip"
  } unless defined?(DECOMPRESSION_COMMANDS)

  def self.applyable?(parent, message)
    return false unless parent.class == FileMeta 
    $log.debug{"Extname for file is: #{parent.read_option("extname")}"}
    res = self.compressed_extname?(parent.read_option("extname"))
    $log.debug{"This file is compressed."} if res
    res
  end

  def self.compressed_extname?(extname)
    if DECOMPRESSION_COMMANDS[extname] then true else false end
  end
  
  def read_option(name)
    parent.read_option(name)
  end

  def filetype
    parent.filetype
  end
  
  def self.create_meta(meta_message, message)
    if self.applyable?(meta_message,message)
      extname = meta_message.read_option("extname")
      cmd = DECOMPRESSION_COMMANDS[extname]

      tmpf = "#{Dir.tmpdir}/CompressMeta-{Process.pid}"
      File.open(tmpf + extname ,"w") {|f| f.write(message.msg)}
      throw "'#{cmd} #{tmpf}#{extname}' not successful!" unless system("#{cmd} #{tmpf}#{extname}")
      msg = File.open(tmpf ,"r") {|f| f.read}
      FileUtils.rm(tmpf)
      
      return self.new.prisma_initialize(meta_message,{:extname => extname,
			:inflate_command => cmd,
			:inflated_size => msg.length,
			:deflated_size => message.msg.length,
			:message => msg })
    end
  end
  
end
