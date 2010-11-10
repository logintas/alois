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

  class SourceDbMeta < ActiveRecord::Base
    description "Metadatas for database sources (pumpy raw table imports)."
    
    def raw_class
      return @raw_class if @raw_class
      @raw_class = eval "#{self.raw_class_name}"
      return @raw_class
    end
    
    def prisma_initialize( p_type, r_class, count=nil, current = nil, execute_once = false, waiting_time = nil )
      if not waiting_time 
	if r_class.respond_to?(:default_waiting_time) then
	  waiting_time = r_class.default_waiting_time
	else
	  waiting_time = $default_waiting_time || 5
	end
      end

      if not count
	if r_class.respond_to?(:default_count) then
	  count = r_class.default_count
	else
	  count = $default_count || 100
	end
      end
      
      self.process_type = p_type
      self.start = current
      self.total = 0
      self.current = current
      self.count = count
      @raw_class = r_class
      self.raw_class_name = r_class.name
      self.execute_once = execute_once
      self.waiting_time = waiting_time
      self.save

      @archivator = nil
      throw "No archive pattern defined! Please specify in the config." unless $archive_pattern
      
      @archivator = Archivator.new($archive_pattern, r_class)      
      self
    end
    
    def may_contain_dublettes
      return true if raw_class.respond_to?(:may_contain_dublettes) and
	raw_class.may_contain_dublettes
      return false
    end

    def messages
      skip_count = 0
      max_count_time_per_iteration = 0.1

      return nil if self.finished
      raise LocalJumpError unless block_given?

      profile = false
      require 'ruby-prof' if profile
      begin
	m_table = eval "#{raw_class}.table_name"
	
	while not $terminate
          RubyProf.start if profile
	  case self.process_type
	  when :fifo, :firsts
	    query = "SELECT #{m_table}.* FROM #{m_table} ORDER BY id ASC LIMIT #{self.count}"
	  when :lasts
	    query = "SELECT #{m_table}.* FROM #{m_table} ORDER BY id DESC LIMIT #{self.count}"
	    # don't know if this is still correct (id > self.ucrrent?)
	    #when :from_id
	    #if self.current == nil then
	    #  query = "SELECT #{m_table}.* FROM #{m_table} ORDER BY id ASC LIMIT 1"
	    #else
	    #  query = "SELECT #{m_table}.* FROM #{m_table} WHERE id > #{self.current} ORDER BY ID ASC LIMIT #{self.count}"
	    #end
	  when :all
	    if self.current == nil then
	      query = "SELECT #{m_table}.* FROM #{m_table} ORDER BY id ASC LIMIT #{self.count}"
	    else
	      query = "SELECT #{m_table}.* FROM #{m_table} WHERE id > #{self.current} ORDER BY id ASC LIMIT #{self.count}"
	    end
	  end
	  
	  $log.debug("Getting messages with #{query}") if $log.debug?
	  iter = raw_class.send(:find_by_sql,query)
	  loop_count = 0
	  main_start = Time.now

	  first = iter.first
	  last = iter.last
	  
	  begin
	    Prisma::Database.transaction(self.class) do
	      iter.each { |raw_message|
		loop_count += 1
#		cost = Benchmark.measure {		
		  @archivator.archivate(raw_message) if @archivator		
		  yield raw_message
		  self.current = raw_message.id		  
#		}.real
		#p "#{cost}s: #{raw_message.inspect}"
		if $terminate
		  $log.debug { "db_source, going to terminate."}
		  break
		end
	      }
	    end
	  rescue ActiveRecord::Transactions::TransactionError
	    self.finished = true
	    self.save
	    raise $!
	  end
	  
	  if first and last
	    Prisma::Database.transaction(raw_class) do
	      if self.process_type == :lasts
		# ex: 100 <= id AND id <= 200
		raw_class.delete_all "#{first.id} >= id AND id >= #{last.id}"
	      else
		# ex: 100 <= id AND id <= 200
		raw_class.delete_all "#{first.id} <= id AND id <= #{last.id}"
	      end
	    end
	  end
	  @archivator.close_unused_files if @archivator

	  main_ende = Time.now
	  main_cost = main_ende - main_start

          done_one = loop_count > 0
          if self.process_type == :all and not done_one or self.execute_once
            self.finished=true
            self.save
            return
          end
          if not done_one then
            Prisma::Util.perf{"No new record in table #{m_table}. Waiting #{self.waiting_time} seconds."}
	    count, rest = self.waiting_time.divmod(5)
	    count.times {
	      Prisma::Util.save_sleep(5)
	      # keep connection alive
	      raw_class.find(:first)
	      self.save
	      break if $terminate
	    }
	    Prisma::Util.save_sleep(rest)
	    
          else
            self.start = self.current if self.start == nil
	    case self.process_type
	    when :lasts, :fifo, :firsts
	      if skip_count > 0
		skip_count -= 1
		Prisma::Util.perf{"Slow count, skipping todo counting for another #{skip_count} iterations"}
	      else		
		t = self.todo
		count_time = Benchmark.measure {
		  case self.process_type
		  when :fifo, :firsts
		    self.todo = raw_class.connection.select_value("select (select id from #{raw_class.table_name} order by id desc limit 1) - (select id from #{raw_class.table_name} limit 1)").to_i
		  else
		    self.todo = raw_class.count()
		  end
		}.real
		
		Prisma::Util.perf{"Todo #{self.todo}, todo delta: #{self.todo - t}"} if t

		if count_time > max_count_time_per_iteration
		  skip_count = (count_time / max_count_time_per_iteration).to_i
		  Prisma::Util.perf{"Counttime is #{count_time} > #{max_count_time_per_iteration} Skip counting for #{skip_count} iterations"}
		end
	      end
	    when :from_id
	      self.todo = raw_class.count(:conditions => "id > #{self.current}")
	    end
            self.total = self.total + loop_count
            Prisma::Util.perf {"Done #{loop_count} in #{main_cost}s (#{loop_count / main_cost}/s)."}
	    Prisma::Util.perf {"Current record is #{self.current} done #{self.total}."}
          end
          self.save
	  #        end
          if profile
            result = RubyProf.stop
            printer = RubyProf::FlatPrinter.new(result)	 
            str = StringIO.new
            printer.print(str , :min_percent => 3)
            str.string.split("\n").each {|l| $log.perf{l}}
          end
	end
	$log.debug{"Finising source_db #{self.id}"}
	self.finished = true
	self.save
      ensure
	@archivator.close_all_files if @archivator
      end
      $log.info("End transform source db meta with raw class: #{raw_class_name}")
    end

    def to_s
      "<SourceDbMeta #{total} x #{raw_class_name} (#{created_at.strftime("%F %T")})>"
    rescue
      super
    end
    
  end
