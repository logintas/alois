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

  class SyslogdMeta < ActiveRecord::Base
    
    description "Meta information for syslogd a syslogd log."
    sources ["SourceDbMeta","ArchiveMeta"]

    def original
      # if not log_meta record is
      # defined, we do not know the
      # archive that the record is
      # saved in, so exit
      return [] unless log_meta

      log_date = log_meta.date

      if self.respond_to?(:queue_id) and (qid = self.queue_id)
	# we know the id that should be in the archive
	Archivator.find({:log_date => log_date,
			  :raw_class => SyslogdRaw,
			  :id=> qid})	
      else
	# do the old way with regexps
	regs = []
	inv_classes = []
	self.children_recursive.reverse.each {|ch|
	  inv_classes.push(ch.class) if ch.class.respond_to?(:invers_before_filter)
	  
	  ch.class.columns.each {|column|
	    next if column.name =~ /^id$/ or column.name =~ /_id$/ or column.name =~ /meta_type_name/
	    val = ch.send(column.name)
	    
	    inv_classes.each {|klass|
	      #p [val,klass.name]
	      val = klass.invers_before_filter(val)
	      #p val
	    }
            val = val.strftime("%T") if column.name == "time" and val.class.name =~ /Time/
	    esc = Regexp.escape(val.to_s.gsub("\"","\\\\\\\\\\\""))
	    regs.push(Regexp.new(esc))
	  }
	}
	#      regs.push(Regexp.new("time: \"#{log_meta.time}\"\n  date: \"#{log_meta.date}\"\n"))
	Archivator.find({:log_date => log_date,
			  :raw_class => SyslogdRaw,
			  :regexps => regs})
      end
    rescue 
      $!.message
    end

    def log_meta
      LogMeta.find_by_syslogd_metas_id(self.id)
    end
    
    def SyslogdMeta.create_meta( source_meta, msg)
      if msg.class == SyslogdRaw then
 	new_meta = SyslogdMeta.new.prisma_initialize(source_meta, 
				   { :ip => msg.ip,
				     :facility => msg.facility,
				     :priority => msg.priority,
				     :level => msg.level,
				     :tag => msg.tag,
				     :program => msg.program,
				     :queue_id => msg.id
				   }
				   )

	log_meta = LogMeta.new.prisma_initialize(new_meta, {
				 :date => msg.date,
				 :time => msg.time,
				 :host => msg.host,
				 :message => msg.msg} )
	return log_meta
      end
      return nil
    end
  end  
