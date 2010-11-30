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

module Prisma

  class Transform
    # Transform all raws from the given raw class
    def self.transform_all_raws(raw_class)
      source = SourceDbMeta.new.prisma_initialize(:all, raw_class)
      source.transform
    end
    
    # Creates a new FileRaw and transform content (use this to import
    # log files)
    def self.transform_file(filename,options = nil)
      source = FileRaw.create(filename,options)
    end
    
    def self.transform_messages(limit = 100)
      #    [ 'HUP' , 'INT' , 'TERM', 'USR1', 'USR2'].each {|s|
      #      Signal.trap(s) {
      #	$log.error("SIGNAL---#{s}") rescue $log.error("aaaaaaaaaasldkfj")
      #      }
      #    }
      #    Signal.trap("TERM") do
      #      # End current tranform.
      #      $log.error "Caught #{Process.pid} signal TERM." if $log.info?
      #      $log.error "Going to stop..." if $log.info?
      #      $terminate = true
      #    end
      $terminate = false
      
      last_id = 0
      total = 0
      iter = Message.find(:all,:conditions => "ID>#{last_id}" ,:limit => limit,:order=>"id")
      while iter.length > 0 and not $terminate
        main_cost = Benchmark.measure {
          iter.each { |message|
            $log.info("Transforming message #{message.id}") if $log.info?
            meta = message.parent
            if meta == nil then
              $log.warn("Message has no meta entry.") if $log.warn?
            else
              Prisma::Database.transaction(meta.class) do
                meta.transform	    
              end
            end
            last_id = message.id
          }
        }.real
        
        total = total + iter.length
        
        Prisma::Util.perf {"Done #{limit} in #{main_cost}s (#{limit/ main_cost}/s)."}
        Prisma::Util.perf {"Current message is #{last_id} done #{total}."}
        
        iter = Message.find(:all,:conditions => "ID>#{last_id}" ,:limit => limit,:order=>"id")
      end
    end
    
    # TODO: comment transform_queues function
    # transform all available dbsources
    def self.transform_queues(type = :fifo, count = nil, waiting_time=nil)
      if $do_not_run_prisma
        $log.error{ "Will not start primsa queues cause option do_not_run_prisma is defined"}
        return
      end
      pids = []
      for klass in get_classes(:raw)
        $log.warn("Starting queue for class #{klass.name}.")
        pid = fork do
          define_new_logger(klass.name)
          Prisma.reconnect
          
          #	Signal.trap("USR1") do
          #	  # End current transform and begin new transform
          #	  $log.info "Child #{Process.pid} caught signal USR1" if $log.info?
          #	  $log.info "Going to restart..." if $log.info?
          #	  $restart = true
          #	  $terminate = true
          #	end
          Signal.trap("TERM") do
            # End current tranform.
            $log.warn{"Caught #{Process.pid} signal TERM."}
            $log.warn{"Going to stop..."}
            $restart = false
            $terminate = true
          end
          
          source = nil
          $restart = true
          while $restart
            $terminate = false
            $restart = type != :all
            begin
              $log.info "Process last records of class #{klass.name}, #{count} per step" if $log.info?
              if source 
                source.finished = true
                source.save	      
              end
              source = SourceDbMeta.new.prisma_initialize(type, klass, count,nil, false, waiting_time)
              $enable_dublette_recognition = source.may_contain_dublettes
              source.transform
            rescue ActiveRecord::Transactions::TransactionError
              raise $!
            rescue	    
              $log.error{ "Processing class #{klass.name} threw error #{$!}!" }
              for line in $!.backtrace
                $log.error{"#{line}"}
              end
              if Prisma::Database.check_connections
                $log.fatal{"Connections are good, so something bad happened. Will not risk to restart queue #{klass.name}."}
                $terminate = true
                $restart = false
              else
                $log.info{"At least one prisma connection is down."}
                connection_wait_count = 1
                while not (Prisma::Database.check_connections or $terminate)
                  wait_time = connection_wait_count
                  wait_time = 30 if wait_time > 30 
                  $log.warn{"#{connection_wait_count} Waiting #{wait_time} seconds."}
                  Prisma.save_sleep(wait_time)
                  connection_wait_count += 1
                end
                if !$terminate
                  $log.info{"Connection are good again. Restarting queue #{klass.name}."}		
                end
              end
            end
          end
          $log.info "Child #{Process.pid} end." if $log.info?
          $log.info "Stopped processing class #{klass.name}." if $log.info?
        end
        pids.push(pid)
      end
      #    Signal.trap("USR1") do
      #      # End current transform and begin new transform
      #      $log.info "Caught signal USR1" if $log.info?
      #      $log.info "Going to restart prismas." if $log.info?
      #      for pid in pids
      #	Process.kill("USR1",pid)
      #      end
      #    end
      Signal.trap("TERM") do
        # End current tranform.
        $log.warn{"Caught signal TERM."}
        $log.warn{"Going to stop prismas."}
        $terminate = true
        $log.error{"No pids found."} if pids.nil? or pids.length == 0
        for pid in pids
          $log.warn{"Sending term to #{pid}."}
          Process.kill("TERM",pid)
        end
      end
      
      $log.debug "Parent process waiting." if $log.debug?
      while !$terminate
        sleep 1
      end
      $log.warn{"Going to wait for children."}
      for pid in pids
        ret = Process.wait
        $log.warn{"Child returned with:#{ret}"}
        $log.error{"Child #{ret} returned without shutdown!"} if not $terminate and not type==:all
      end
      $log.warn{"Prisma main process ended."}
    end
    
  end
end
