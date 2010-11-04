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

require "yaml"
require "zlib"
begin
  require "mysql"
rescue LoadError
  print "Unable to load mysql library #{$!}\n"
end

def question_continue
  unless defined?(LIBISI)
    print "Do you want to continue? Press ENTER, CTRL-C to abort\n"
    STDIN.readline
  else
    exit 1 unless $ui.question("Do you want to continue?", :default => false)
  end
end

def get_password(name)  
  return ENV["db_#{name}_password".upcase] if ENV["db_#{name}_password".upcase]
  raise "Libisi not available, cannot get password for #{name}" unless $ui
  $ui.password("Please enter #{name} password")
end

def check_mysql_password

  # try to make a connetion on the localhost trough root without a pw
  begin
    dbh = connect_mysql_local_real(nil)

    # if we reach here, this is bad, 
    # no password is defined for root
    # ask user...

    raise "Mysql has no root password defined, will not continue" unless
      defined?(LIBISI)
    raise "No mysql root password set" unless 
      $ui.question("No password for root user defined!!\nYou must define one to continue.\nDo you want to define one now?")
    password = set_mysql_password("ALL", "*", "root@localhost")  
  rescue
    raise if not $!.to_s =~ /Access denied for user/
    $log.debug("OK there is a root pw!") if $log
  end
end


def set_mysql_password(privileges, object, person, password = nil)  
  raise "Libisi not available, cannot set new password." unless $ui
  if password == nil then    
    print 
    password = $ui.password("Set #{privileges} for #{object} to #{person}...\nPlease enter new password")
    password2 = $ui.password("Please reenter new password")
    raise "Password did not match!" if not password2 == password
    raise "No password entered!" if password == "" or password == nil
    raise "Do not use '\"'!" if (password =~ /\"/)
  end

  query = "GRANT #{privileges} PRIVILEGES ON #{object} TO #{person} IDENTIFIED BY \"#{password}\""
  $log.info("Executing #{query.inspect}")
  connect_mysql_local_real(nil).query(query)
  password
end

# redirect to libisis host_name
def hostname; host_name; end

def db_root_password
  check_mysql_password
  # get the rootpassword 
  @password ||= (ENV["DB_ROOT_PASSWORD"] or get_password("root"))
  @password
end

def connect_activerecord_local(db = "mysql")
  ActiveRecord::Base.establish_connection({
					    :adapter => "mysql",
					    :database => db,
					    :host => "localhost",
					    :username => "root",
					    :port => 3306,
					    :password => db_root_password
					  })
end

def connect_mysql_local_real(pw, db = "mysql")
  Mysql.real_connect("localhost", "root", pw, db)
end

def connect_mysql_local(database = "mysql")
  conn = connect_mysql_local_real(db_root_password, database)  
end


class Object
  # computes a hash of a yaml serialization
  # sort the lines first to get the same result
  # even if attribute order changed.
  def Object.yaml_hash(yaml)
    yaml.split("\n").sort.join("\n").hash
  end
  
  # Load object from yaml
  def Object.from_yaml(yaml)
    ret = YAML.parse(yaml).transform
    # fix, otherwise attributes_methods:160 will complain nil.[] on cached methods
    ret.instance_eval("@attributes_cache ||= {}")
    ret
  end

  # Load object from zipped yaml
  def Object.from_zip(zip)
    i = Zlib::Inflate.new()
    i.inflate("x\234")
    return from_yaml(i.inflate(Base64.decode64(zip)))
  end

  # Serialize object to zipped yaml
  def Object.to_zip(obj)
    d = Zlib::Deflate.new()
    d.deflate(obj.to_yaml)
    return Base64.encode64(d.deflate(nil))
  end
  # Calls Objects to_zip function
  def to_zip
    Object.to_zip(self)
  end

  # Helper function for loading ipranges from a file. Executes Class.create for each entry.
  def Object.load_from_yaml(filename)
    yaml_string = ""
    yaml_string << IO.read(filename)
    yaml = YAML::load(yaml_string)    
    yaml.each {|vals|
      self.create(vals[1])
    }
  end
  
  # Use from_yaml function of prisma for loading classes
  def from_yaml(yaml)
    self.class.from_yaml(yaml.strip)
  end

  # returns prisma yaml_hash
  def yaml_hash
    yaml = self.to_yaml
    return Object.yaml_hash(yaml)
  end

  # TODO: describe this, is this still needed?
  def load_from_yaml(filename)
    yaml_string = ""
    yaml_string << IO.read(filename)
    yaml = YAML::load(yaml_string)    
    yaml.keys.sort.select {|name|
      !self.respond_to?(:name) or !self.find_by_name(yaml[name]["name"])
    }.map {|name|
      self.create(yaml[name]) rescue $!.to_s
    }
  end
  
  # Use from_zip of prisma
  def from_zip(zip)
    self.class.from_zip(zip)
  end
  
  alias_method :orig_to_yaml, :to_yaml
  # This instance variables may not be serialized
  # this constant is only used for yaml serialization
  BAD_INSTANCE_VARIABLES = ["@datasource","@attributes_cache",
                            "@source_table_class","@table","@view","@report_template",
                            "@sentinel"] unless defined?(BAD_INSTANCE_VARIABLES)

  # Removes BAD_INSTANCE_VARIABLES and yields
  # a block. Instancevariables are set again
  # afterwards.
  def remove_bad_instance_variables(&block)
    tmp = {}      
    BAD_INSTANCE_VARIABLES.each {|var|
      tmp[var] = remove_instance_variable(var) if
      instance_variable_defined?(var)
    }
    if block
      ret = yield
      tmp.each {|var,val| instance_variable_set(var,val)}
      ret
    end
  end
  

  # New to_yaml function that removes BAD_INSTANCE_VARIABLES
  # before serializing. Original to_yaml function can be
  # called with orig_to_yaml, but will probably not work.
  def to_yaml( opts = {})
    remove_bad_instance_variables {
      self.orig_to_yaml(opts)
    }
  end
           
end

class ActiveRecord::Base
  def self.description(val=nil); return @desc unless val; @desc = val;end

  def self.connection_approx_count(connection, table_name)
    case connection.class.name
    when /Mysql/
      res = connection.execute("SHOW TABLE STATUS LIKE '#{table_name}'")
      res = res.fetch_hash
      return nil unless res
      a_count = res['Rows'].to_i
    else
      $log.warn("Approx count not implemented for #{connection.class.name}")
      return nil
    end
  rescue ActiveRecord::Transactions::TransactionError
    raise $!
  end

  def self.approx_count
    if self.respond_to?(:alois_connection) and conn = self.alois_connection      
      val = connection_approx_count(conn, self.table_name)
      return val if val and val > 20000
    end

    return count
  end

  def self.connection_auto_increment(connection, table_name)
    case connection.class.name
    when /Mysql/
      res = connection.execute("SHOW TABLE STATUS LIKE '#{table_name}'") 	
      res.fetch_hash['Auto_increment'].to_i
    when /SQLite/
      res = connection.execute("select * from SQLITE_SEQUENCE WHERE name = '#{table_name}'")
      return(0) if res == []
      res[0]["seq"].to_i
    else
      raise "Autoincrement not implemented for #{connection.class.name}"
    end    
  rescue ActiveRecord::Transactions::TransactionError
    raise $!
  end

  def self.auto_increment
    if self.respond_to?(:alois_connection) and conn = self.alois_connection      
      return connection_auto_increment(conn, table_name)
    else
      raise "Autoincrement not implemented"
    end
  end


  def self.alois_connection
    self.connection
  end

  # Clone, remove bad instancevariables
  def full_clone
    res = self.clone
    res.remove_bad_instance_variables
    if self.id
      attrs = res.send :instance_variable_get, '@attributes'
      attrs[self.class.primary_key] = self[self.class.primary_key]
    end
    res.instance_eval("@attributes_cache ||= {}")
    res
  end

end
