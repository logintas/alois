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

# This class contains helper and basic functions for all
# meta and raw classes.
require "active_record"

module BaseMixin

  module ClassMethods
    
    # defines finder function for messages, all
    # meta classes can have a message associated
    # to it
    def inherited(subclass)
      super
      subclass.set_table_name undecorated_table_name(subclass.name)
      subclass.module_eval do
	has_many :messages,
        :foreign_key => "meta_id",
        :conditions => "meta_type_name = 'Prisma::#{subclass.name}'"
        #	  :dependent => :delete_all
        #	  :finder_sql => "SELECT * FROM messages WHERE 	"AND meta_id = {id}"
      end
    end
    
    # The foreign column name that another class would have
    # if it refers to this
    def foreign_column_name(klass_name = nil)
      return undecorated_table_name((klass_name or self.name)) + "_id"
    end
    
    # Defines preseed expression. Preseed expressions are
    # regular expressions that must match for all logs
    # that will be stored in this class. This functionality is mainly for
    # speedup. After a log matched any of these preseed expressions,
    # normal processing/parsing wild be done.
    def preseed_expression(expr = nil)
      @preseed_expression = expr if expr
      return @preseed_expression
    end
    
    # Check if this (parent) class with its message
    # is applyable for the current class. True if any
    # preseed_expression matches the message.
    $expression_count = 0
    def applyable?(parent, message)
      if self.respond_to?(:preseed_expression) and self.preseed_expression != nil then
	$expression_count += 1
	$log.debug {"Comparing '#{message.msg}' =~ #{self.preseed_expression}"}
	case message
	when Message
	  return message.msg =~ self.preseed_expression
	when String
	  return message =~ self.preseed_expression
	else
	  raise "Unexpected message class #{message.class}"
	end
      end
      return true
    end
    
    # Adds relations to source classes
    def sources(array = nil)
      return (@sources or []) unless array
      @sources = array
      @sources.each { |klass_name|	
	# f_col_name = klass.table_name + "_id"
	#	unless column_names.index(f_col_name)
	#	  connection.add_column(table_name, f_col_name, :integer)
	#	  connection.add_index(table_name,f_col_name)
	#	  reset_column_information()
	#	  $log.warn{"Added column #{f_col_name} to table #{table_name}"}
	#	end
	#      	p "#{self.name} belongs_to #{undecorated_table_name(klass.name).singularize.to_sym}, with key #{undecorated_table_name(self.name) + "_id"}"
	belongs_to undecorated_table_name(klass_name).singularize.to_sym,
        :class_name => klass_name,
        :foreign_key => self.foreign_column_name(klass_name)
      }
    end
    
    # returns all child meta classes of this class
    def child_classes
      Prisma::Database.get_classes(:meta).select {|klass|
	klass.columns_hash[self.foreign_column_name]
      }
    end
    # returns all parent meta classes of this class
    def parent_classes
      Prisma::Database.get_classes(:meta).select {|klass|
	self.columns_hash[klass.foreign_column_name]
      }
    end
    # checks weather the given class is a parent of this
    def parent_class?(klass, done = [])
      parents = self.parent_classes.reject {|p| done.include?(p)}      
      my_done = done.dup
      my_done.push(self)
      parents.include?(klass) or 
	parents.select {|p| p.parent_class?(klass,my_done)}.length > 0
    end
    # checks weather the given class is a child of this
    def child_class?(klass, done = [])
      children = self.child_classes.reject {|p| done.include?(p)}      
      my_done = done.dup
      my_done.push(self)
      children.include?(klass) or 
	children.select {|p| p.child_class?(klass,my_done)}.length > 0
    end
    
    # Return true if this class can parse the given class
    def can_transform?(klass)
      true if sources.index(klass.name) 
    end

    # Return true if the this class can have messages
    def may_have_messages?; true; end
    
    # for compatibility reason. With this on both, views
    # and tables the table can be gotten with obj.table
    def table
      self
    end
    
    # A description for this class can be defined.
    def description text = nil
      return @description unless text
      
      @description = text if text
      @description
    end
    # Returns the description in html format
    def description_html
      r = "<p>#{description}</p>"
      if self.respond_to?(:expressions)
        self.expressions.each {|exp|
          r += "<p>#{exp[:regex].inspect} => #{exp[:fields].inspect}</p>"
        }
      else
	r += "<p style='background-color:orange'>No regularexpressions to use</p>"
      end
      r
    end
    
    
    # Check if table exist. If not, a exception is raised.
    def check_table
      throw "Table '#{table_name}' does not exists." unless table_exists?
    end
    
    # Return a table status, if exist return "OK", a error message instead.
    # no exception will be risen.
    def status
      begin
	check_table
	return "OK"
      rescue ActiveRecord::Transactions::TransactionError
        # This have to be, that transactions are working
	raise $!
      rescue
	return $!.message.to_s
      end
    end
    
    # Create a new record (not saved yet), if this is possible for
    # the given parent meta.
    # expressions are used to parse message.
    def create_meta(meta, message)
      return nil unless self.applyable?(meta, message)
      if self.respond_to?(:expressions) then
	ret = nil
	my_message = case message
		     when Message
		       message.msg
		     when String
		       message
		     end
	$log.debug("Trying to match #{my_message.inspect}") if $log.debug?
	match, values = self.match_regexps(my_message, meta.class, meta)
	return self.new.prisma_initialize(meta,values) if values
      else
	$log.warn("#{name} has no create method defined.") if $log.warn?
	return nil
      end
      return nil
    end
    
    # Try to match regular expressions against my_message. If regular expressions
    # match, the first match will be returned with the matched values. (a array with
    # [regexp, {:key => :val ...}]
    # TODO: explain that in detail
    def match_regexps(my_message, meta_class, meta_instance)
      return nil unless self.respond_to?(:expressions)
      for expr in self.expressions
	next if expr[:condition] and !expr[:condition].call(my_message, meta_class, meta_instance)
        
	$log.debug{"Comparing to #{expr[:regex]}."}
	my_message = self.before_filter(my_message) if self.respond_to?(:before_filter)
	$expression_count += 1
	if my_message =~ expr[:regex] then
	  $log.debug{"Regular expression #{expr[:regex]} matched."}
	  results = Regexp.last_match.to_a[1..-1]
	  if expr[:result_filter]
	    $log.debug{"Results before filter: #{results.inspect}"}
	    results = expr[:result_filter].call(results, meta_instance) 
	  end
	  $log.debug{"Results: #{results.inspect}"}
	  $log.debug("Fields:  #{expr[:fields].inspect}") if $log.debug?
	  if results.size != expr[:fields].length
	    throw "Regexp matched (#{results.size}) more than fields (#{expr[:fields].length}) defined. (Res: #{results.inspect} Tansform against: #{self.name})"
	  end
	  
	  values = {}
	  expr[:fields].each_with_index {|field, i|
	    next if field.nil?
	    val = results[i]
	    next if val.nil?
	    if values[field].nil?
	      values[field] = results[i]
	    else
	      values[field] += results[i]
	    end
	  }
	  $log.debug{"Regexp created values: #{values.inspect}"}
	  for name,value in values
	    throw "#{name} has no value!" if value == nil
	    #                throw "#{name} has no value!" if value == ""
	  end
	  return [expr, values]
	end
      end      
      return nil
    end
        
  end

  module InstanceMethods

    # Returns the message of this instance (if there is any)
    # TOOD: Rework this. rescue LocalJumpError is quite hackish
    def message
      return @message_fast if @message_fast
      msgs = nil
      begin
	msgs = messages
      rescue LocalJumpError
      end
      return nil unless msgs
      ms = msgs.size
      if ms > 1	
	messages.each { |m| $log.warn{"Found message '#{m.to_s}'"}}
	throw "More than one (#{ms}) message in messages for #{self.class.name}.#{self.id}!"
      end
      return nil if ms == 0 
      return msgs[0]
    end

    # use this if you already set association
    # and you do not want collection perfomance loss
    def message_fast=(val)
      @message_fast = val
    end

    # Sets a new message for this class
    def message=(val)
      messages.each { |m| m.prisma_destroy }
      if val
	if val.class == String
	  # new will automatically add
	  # the message
	  Message.new.prisma_initialize(self, val)
	else
	  messages << val
	end
      end
    end

    # Initializes a new meta with parent and values (like attribtues in active_record),
    # after values are set, after_filling_values(values) will be called if it exist. Maybe
    # a corresponding activerecord method with callbacks exists now.
    # If a value :message is given, a message object is created too.
    # At the end self.after_init(values) will be called if it exist.
    # Maybe this is a little bit confusing because new does already save the new record.
    # This is because of historical reason and could maybe changed in future. This corresponds
    # more to create of activerecord than to new.
    def prisma_initialize(parent = nil, values = nil)
      $log.debug("Creating instance of '#{self.class.name}' with parent '#{parent.class.name}'")
      raise "Parent is nil" if parent.nil?

      unless self.class.name =~ /Meta$/
	$log.debug{"This is not a meta record. exiting base_mixin constructor."}
	return self
      end

      if parent
	parent.save if parent and parent.new_record?
	self.parent = parent
      end

      if self.respond_to?(:init)
	# call init from class
	self.init(values)
      else
	# write values to instance
	if values != nil then
	  for name, value in values
	    next if name == :message
	    if self.respond_to?("#{name}=") 
	      # write value to property		
	      if name == :date and name.class == String
		begin
		  value = DateTime.strptime(value, "%d.%m.%Y")		  
		rescue ActiveRecord::Transactions::TransactionError
		  raise $!
		rescue
		  $log.warn{"#{value} not parsed as date (#{$!.message})."}
		end
	      end
	      self.send("#{name}=",value) unless name == :message
	    else
	      # Maybe there is an anonymous field?
	      if self.respond_to?("#{name}_anonym=") 
		# yes - so anonymise that
		nonym = Nonym.find_or_create(value)
	      self.send("#{name}_anonym=",nonym.id)		  
	      else
		# no. Giving up!
		throw "Neither field '#{name}' nor anonymous field '#{name}_anonym' found in class #{self.class.name}."
	      end
	    end
	  end
	end
      end

      self.after_filling_values(values) if self.respond_to?(:after_filling_values)
      
      # validation is too expensive, but we know the records are correct.
      self.save_without_validation
      
      # special treatment of columns message and user	
      if values and values.has_key?(:message) and values[:message]
	msg = Message.new.prisma_initialize(self,values[:message], {:fast_association => true})		
        msg.save_without_validation
	
	# write hash
	if self.respond_to?(:hash_value)
	  self.hash_value = self.get_hash
	end
#	msg.meta_id = self.id
      end
      
      self.after_init(values) if self.respond_to?(:after_init)
      self
    end
    
    
    # Reproducable means, that all data in the log is now stored in the
    # database and thus the original message can be deleted. However,
    # the raw/original message should still be accessible in archive)
    def reproducable?
      true
    end
    
    # Main "parsing" function. When transform for a raw-message or any
    # other meta message is called, all resulting meta message will be
    # generated. Probably (if there is a transformation), the related
    # message of this meta will be deleted.
    def transform(options = {})
      begin
	default_transform(options)
	#p ("---------" + SourceDbMeta.count.to_s)
      rescue ActiveRecord::Transactions::TransactionError
	raise $!
      rescue
	begin
	  $log.error{"Transform class #{self.class.name}.#{self.id} threw error: #{$!}!" }
	  msg = (self.message.msg[0,256] rescue nil)
	  $log.error("Message is #{msg.inspect}") if msg
	  $log.error("#{self.inspect}")
	  for line in $!.backtrace
	    $log.error{"#{line}"}
	  end
	  if not Prisma::Database.check_connections
	    throw "Prisma connection failed!"
	  end
	  raise if options[:raise_exception]
	rescue ActiveRecord::Transactions::TransactionError
	  raise $!
	rescue
	  raise if options[:raise_exception]
	  $log.fatal("Printing error threw exception #{$!}!") 
	end
      end
    end
        
    # This method will be called from transform method. If you
    # need special treatment, overwrite transform and not default
    # transform. Default transform uses the regular expressions,
    # and normally overwriting after_filling or after_init gives
    # you enough power for your customisation.
    def default_transform(options = {})
      if $enable_dublette_recognition
	if self.respond_to?(:hash_value) and self.hash_value 
	  others = self.class.find(:all,:conditions => "hash_value = #{self.hash_value}")
	  
	  others.each { |other| 
	    if other.id != self.id
	      raw_meta1 = other.raw_meta
	      raw_meta2 = self.raw_meta
	      if raw_meta1.class != raw_meta2.class or raw_meta1.id != raw_meta2.id
		$log.warn{"Found dublette #{other.id} (hash: #{self.hash_value}, msg:#{self.message.msg[0,100]})!"}
		self.destroy
		return
	      end
	    end
	  }
	end
      end
      
      $log.debug{"Begin transform #{self.class.name}.#{self.id}."}

      def msgs
	# only return the only message
	# if message_fast is set
	if @message_fast
	  yield message
	return
      end
	begin
	  messages.each {|m| yield m }
	rescue LocalJumpError
	  $log.debug("Got local jump error. giving block.")
	  messages { |m|
	    yield m
	  }
	end
      end

      count = 0
      msgs { |message|
	$log.debug("Processing message #{message.to_s}") if $log.debug?
	$log.debug("Message '#{message.msg}'") if $log.debug? and message.msg.length < 200
	reproducable = false
	for klass in Prisma::Database.transformer_classes(self.class)
	  $log.debug{"Transforming against #{klass.name}"}
	  # (fp) enable this again if you want to go trough messages again
	  #            if Meta.find_by_parent_id_and_meta_type_name(self.meta.id, klass.name) != nil and
	  #                not message.class.name =~ /Raw$/ then
	  #                  $log.info "Meta for #{klass.name} already exists." if $log.info?
	  #              next
	  #            end
	  applyable = klass.applyable?(self, message)
	  $log.debug{"Message applyable to #{klass}: #{if applyable then "yes" else "no" end}"}

	  if applyable
	    $log.debug{"Creating meta #{klass.name}"}
	    new_meta = klass.create_meta(self, message)
	    if new_meta
	      count = count + 1
	      $log.debug{"Transformation #{klass.name} returned #{new_meta}"}
	      new_meta.transform(options)
	      reproducable = new_meta.reproducable? or reproducable
	    else
	      $log.debug{"Transformation returned nil"}
	    end
	  end
	end
	$log.debug{"End transform #{self.class.name}.#{self.id}."}
	$log.debug{"Transform result: repr(#{reproducable}) saveable(#{message.respond_to?(:save)})"}
	if not reproducable and message.respond_to?(:save)
	  $log.debug{"Saving message. #{message.id}"}
	  throw "Message not reproducable but already frozen, probably deleted!" if message.frozen?
	  message.create if message.new_record?
	else 
	  message.destroy unless message.new_record? or  message.class.name =~ /Raw$/ 
	end
      }
      return count
    end
=begin    
    def to_sss
      c = ""
      self.children {|ch| c += ch.to_s }
      c = c[0..1023] if c.length > 1024 
      unless self.class == SourceDbMeta
	m = self.messages.to_s
	m = m[0..1023] if m.length > 1024 
      end
      return "#{self.class.name}.#{self.id} Msgs<#{m}> Chld<#{c}>"
    end
=end   

    # Yields all meta chilren of this class.
    def children      
      return [] if self.class.name =~ /.*Raw$/
      $log.debug{"Looking for children of #{self.class.name}.#{self.id}."}
      for klass in Prisma::Database.get_classes(:meta)
	for column in klass.columns
	  if column.name == "#{self.class.table_name}_id" then

            limit = 10
            current = 0
            while current >= 0
	      records = klass.find(:all,
				   :conditions => "#{self.class.table_name}_id = #{self.id}", 
				   :limit => limit, 
				   :offset => current)
	      for rec in records
		yield rec
	      end
	      if records.length == limit
		for rec in records
		  # only increment to current if record has not been deleted
		  current += 1 if !rec.frozen?
		end
	      else
		current = -1
	      end
            end

	  end
	end
      end   
      return []
    end

    # Returns a array of all children
    def children_a
      a = []
      children {|c| 
	a.push(c)
      }
      a.push(message) if message
      a
    end

    # Destroys the meta and all its children
    # currently quite slow, needs reimplementation
    # of meta classes modell.
    def prisma_destroy
      $log.debug{"Destroying #{self.inspect}"}
      if Prisma::Database.speed_transaction_enabled      
	$destroy_calls_speed ||= 0
	$destroy_calls_speed += 1
      else
	$destroy_calls ||= 0
	$destroy_calls += 1
      end
      unless self.class == Message
	children {|c|
	  Prisma::Database.speed_transaction(c) {
	    c.prisma_destroy
	  }
	}
	message.prisma_destroy if message
      end
      destroy
    end

    # Traverse all childern recursively and returns
    # a array of them (breath-first)
    def children_recursive
      a = []
      arr = children_a
      arr.each {|c|
	a += c.children_recursive
      }
      a + arr
    end


    # Build a query that will return all
    # records that have the same "path" as 
    # the current one. Used for building queries
    # in the UI
    def join_query(query=nil)
      query = "#{self.class.table_name}" unless query
      p = parent
      if p then
	query = "#{query} LEFT JOIN #{p.class.table_name} ON #{self.class.table_name}.#{p.class.foreign_column_name} = #{p.class.table_name}.id"
	query = p.join_query(query)
      end
      return query
    end  

    # TODO: document this
    def get_join
      ret = "LEFT JOIN messages ON messages.meta_id = #{table_name}.id " +
	"AND messages.meta_type_name = '#{self.class.name}' "
      if self.class.respond_to?(:additional_columns)
	previous_table_name = self.class.table_name
	for table_class, table_columns in self.class.additional_columns
            ret += "LEFT JOIN #{table_class.table_name} "
	  ret += " ON #{table_class.table_name}.id = "
	  ret += "    #{previous_table_name}.#{table_class.foreign_column} "
	  previous_table_name = table_class.table_name
	end
      end
      return ret
    end
    
    # Count childern (one level only)
    def children_count
      i = 0
      children { |c| i+=1}
      return i
    end

    # return parent meta, works also for views by using
    # class in source_table_class as parent class
    def parent
      if self.class.respond_to?(:sources)
	self.class.sources.each { |klass_name|
	  p = self.send(eval(klass_name).table_name.singularize)
	  return p if p	
	}
      end
      if self.class.name != "Message" and self.class.respond_to?(:parent_classes)
	self.class.parent_classes.each { |klass|
	  if self.respond_to?(klass.foreign_column_name) and (mid = self.send(klass.foreign_column_name))
	    return klass.find(mid)
	  end
	}
      end
      view = View.get_class_from_tablename(self.class.table_name)
      source_table_class = view.source_table_class if view
      if source_table_class
	return source_table_class.table.find(self.id)
      end
      return nil	
    end

    # Sets the parent instance
    def parent=(val)
      return nil unless self.class.respond_to?(:sources)
      self.class.sources.each { |klass_name|
	self.send("#{eval(klass_name).table_name}_id=",nil)
      }
      self.send("#{val.class.table_name}_id=",val.id) if val
    end

    # Finds the original message for this meta, default behaviour
    # is to return parent.original. For every raw class there sould
    # be a corresponding meta class which then implements the original
    # function in detail
    def original
      p = parent
      return [] unless p
      p.original
    end
    # Returns a text describing original message (not the object)
    def original_text
      o = original
      case o
      when String
	"ALOIS_ERROR: #{o}"
      when NilClass
	"NO ORIGINAL FOUND"
      else
	o[0].msg
      end
    end
    
    # returns a time string of the time field,
    # thin this string is used for charting in that form
    def time
      begin
	t = super
	t.strftime("%H:%M:%S")
      rescue ActiveRecord::Transactions::TransactionError
	raise $!
      rescue
	super
      end
    end
  end

  # Include instance and class methods
  def self::included other
    other.module_eval  { include InstanceMethods }
    other.extend ClassMethods
    other
  end

end
