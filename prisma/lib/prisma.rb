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

raise "PRISMA_ENV constant not defined!" unless defined?(PRISMA_ENV)

require Pathname.new(__FILE__).dirname + "prisma/base_mixin.rb"
class ActiveRecord::Base
  include BaseMixin
end

require Pathname.new(__FILE__).dirname + "prisma/database.rb"
require Pathname.new(__FILE__).dirname + "prisma/transform.rb"
require Pathname.new(__FILE__).dirname + "prisma/archive.rb"
require Pathname.new(__FILE__).dirname + "prisma/archivator.rb"

module Prisma
  class Util
    # Log performance, if logger has a perf
    # function log to it, log to warn otherwise
    def Util.perf
      if $log.respond_to?(:perf)
        $log.perf {yield}
      else
        $log.warn {yield}
      end
    end

    # Sleep function that awakes if $terminate variable is set
    # this is used for prisma daemon, if no new logs are in the
    # queue, the process must sleep but immediately teminate
    # if it sould.
    def Util.save_sleep(time)
      cnt = 0
      while cnt < time and not $terminate 
        sleep(1)
        cnt = cnt + 1
      end
    end
    
    # Defines a new logger with the given name. A new Logfile will
    # be opened and all future log calls to $log will be logged there.
    def Util.define_new_logger(name)
      return if ENV["LOG_OUTPUT"]
      new_level = $log.level
      file = File.join(PRISMA_LOG,name + '.log')
      $log.info("Creating new logfile: #{file}")

      PRISMA_LOG.mkpath unless PRISMA_LOG.exist?
      $log.info("Define new logger '#{name}' to #{file.to_s}.") if $log
      Log.new_logger(name, file)
      #    $log = Log4r::Logger.new(file)
      $log.info("Defined new logger '#{name}' to #{file.to_s}.") if $log
      $log.level = new_level #Logger::WARN
    end    

  
    # Generate random syslogd_raws records - for testing purpose only.
    def Util.generate_random_raws(amount = 100,
				  range = "beginning yesterday until the end of day".to_time_range.to_a)
      range = range.to_time_range.to_a if range.class == String
      amount.times{SyslogdRaw.create_random_test_message(range.rand)}
    end    

    # Generate random syslogd_raws and transform them, the result will be some meta records - for testing purpose only.
    def Util.generate_random_data(amount = 100, 
				  range = "beginning yesterday until the end of day".to_time_range.to_a)
      
      generate_random_raws(amount,range)
      transform_all_raws(SyslogdRaw)
    end
    
  end
end
