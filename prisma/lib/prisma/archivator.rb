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

  # Class for archivating raw messages
  class Archivator

    # Find messages in the archive, conditions is a hash any of
    #  :regexps: array of regular expression that must match the raw line
    #  :id: The id of the raw message
    def self.find(conditions, archive_pattern = $archive_pattern)
      path = Archivator.archive_path(archive_pattern, conditions)
      path = path.gsub(/\%./,"*")
      archive_files = Dir.glob(path)
      archive_files += Dir.glob(path + ".gz")
      conditions[:regexps] ||= []
      archive_files.map {|archive_file|
	arr = []

	if conditions[:regexps].length == 0 and conditions[:id]
	  arr << Archivator.fast_find_message(archive_file, conditions[:id])
	else
	  raise "Not implemented" if conditions[:id]
          Archivator.messages(archive_file, conditions[:regexps]) {|m| arr.push(m)}
	end
	arr
      }.flatten.compact
    end

    # Find a archivated raw message in the archfile by its original id
    def self.fast_find_message(archivfile, id)
      case archivfile 
      when /arch\.gz$/
	grepper = "zgrep"
      when /arch.bz?$/
	grepper = "bzgrep"	
      else
	grepper = "grep"
      end
      cmd = "|#{grepper} ' id: \\\"#{id}\\\"' '#{archivfile}' | head -1".gsub("\\","\\\\\\")
      $log.debug{"Find command for original: #{cmd.inspect}"}
      ret = open(cmd) {|f| f.readlines[0]}
      return nil if ret.nil? or ret.strip == ""
      oret = Object.from_yaml(eval(ret))
      raise "Found object has not correct id #{oret.id.inspect} expected #{id.inspect}" unless
        oret.id.to_s == id.to_s
      oret
    end
    
    # Find a archivated raw messages in the archfile byregular expressions
    def self.messages(archivfile, regexps = [])
      raise LocalJumpError unless block_given?
      regexps.reject! {|r| r == //}
      archivfile = "| /bin/gunzip -c #{archivfile}" if archivfile =~ /\.gz$/
      open(archivfile,"r") {|f|
	f.each_with_index {|line,i|
	  match = true
	  regexps.each { |reg|
	    if match
              match = line =~ reg
              $log.debug {"#{line.inspect} =~ #{reg.inspect} => #{match.inspect}"}
	    end
	  }
	  next unless match
	  msg = nil
	  begin	 
	    # leave this for security (evaluating string)
            if line =~ /^(\S+)\:(\".*\")$/
              $log.debug{"Removing leading filename #{$1}"}
              line = $2
            end
	    throw "Leading and/or tailing \" not found in file '#{archivfile}:#{i}'!" unless line =~ /^".*\"$/
 	    throw "Suspicious line found in file '#{archivfile}:#{i}' (unquoted \" found)!" if line =~ /\".*[^\\]\".*\"/
	    msg = Object.from_yaml(eval(line))

	    msg.origin = "File '#{archivfile}:#{i}'" if msg.respond_to?(:origin)
	  rescue 
	    $log.error "Error getting archive record '#{archivfile}:#{i}'. (#{$!.message})" if $log.error?
	  end
	  yield msg if msg
	}
      }
    end

    # Substitute placeholder in the path
    def self.archive_path(path, conditions)
      path = path.to_s
      if raw_class = conditions[:raw_class]
	path = path.gsub(/\%t/,raw_class.table_name)
	path = path.gsub(/\%c/,raw_class.name)
      end
      if conditions[:incoming_date]
	path = path.gsub(/\%i/, conditions[:incoming_date].to_s)
      end
      if conditions[:log_date]
	path = path.gsub(/\%d/, conditions[:log_date].to_s)
      end
      path
    end

    # Initialize a new Archivator class for raw_class class
    def initialize(path, raw_class)
      path = path.to_s
      $log.info{"Create archivator with path '#{path}' and raw_class '#{raw_class}'."}
      throw "Archivate path have to contain the pattern \%i." unless path =~ /\%i/

      @path = Archivator.archive_path(path, {:raw_class => raw_class })

      @use_message_date = raw_class.respond_to?(:date)
      @open_files = {}
      @used_files = {}
    end
    
    # Do really open the filename (not just lazy opening)
    def really_open_file(filename)
      $log.info{"Going to open archive file '#{filename}'."}
      f = File.new(filename,(File::WRONLY | File::APPEND | File::CREAT))
      FileUtils.chown("prisma","www-data",filename) if PRISMA_ENV == "production"
      
      @open_files[filename] = f
      @used_files[filename] = true
      f
    end


    # Archivate the raw_message in the archive. The
    # class will be serialized to yaml and archivated
    # to the right file depending on the global archivate path.
    def archivate(raw_message)
      if raw_message.respond_to?(:date)
	filename = Archivator.archive_path(@path, {:incoming_date => Date.today, :log_date => raw_message.date})
      else
	filename = Archivator.archive_path(@path, {:incoming_date => Date.today, :log_date => Date.today})
      end
      
      $log.info{"Archivate '#{raw_message.class.name}.#{raw_message.id}' to #{filename}."}
      dir = File.dirname(filename)
      
      unless File.directory?(dir)
	throw "Wanted to create directory '#{dir}' but there exists already a file." if File.exists?(dir)
	FileUtils.mkdir_p(dir)
      end
      FileUtils.chown("prisma","www-data",dir) if PRISMA_ENV == "production"
      
#      @thread.join if @thread
#      # spin off archivation, to_yaml is slow and dic acces maybe also
#      @thread = Thread.fork {
        file = @open_files[filename] || really_open_file(filename)
        dump = "#{raw_message.to_yaml.dump}\n"
        file.write(dump)
#        @thread = nil
#      }
      @used_files[filename] = true
    end

    # Close all archive files, that are not used
    # anymore
    def close_unused_files
      @used_files.each { |filename,used|
	if used
	  @used_files[filename] = false 
	else
	  close_file(filename)
	end
      }
    end
    
    # Close all archive files
    def close_all_files
      @used_files.each { |filename,used|
	close_file(filename)
      }
    end

    # Close file by filename
    def close_file(filename)
      throw "Filename nil" unless filename
      $log.info{"Closing archive file '#{filename}'."}
      @open_files[filename].close
      @open_files.delete(filename)
      @used_files.delete(filename)
    end    

    # Get open files
    def open_files
      return @open_files.length
    end

    # Compress old archive files (pattern is a path
    # with wildchards used for globbing)
    def self.compress_old_files(pattern)
      $log.info{"Looking for archive files '#{pattern}'."}
      for file in Dir.glob(pattern)
	unless file.to_s.include?(Date.today.to_s)
	  throw "Zipped file already exists!" if File.exists?("#{file}.gz")
	  $log.info{"Zipping file '#{file}'."}
	  throw "Error zipping '#{file}'." unless system("/bin/gzip \"#{file}\"")
	else
	  $log.info{"Not zipping file from today '#{file}'."}
	end
      end
    end
  end
