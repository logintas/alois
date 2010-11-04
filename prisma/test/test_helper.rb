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

require "libisi"
init_libisi
#Log.log_level -= 2
PRISMA_ENV = "test"

require 'test/unit'
require File.expand_path(File.dirname(__FILE__) + "/../conf/prisma/environment.rb")

Prisma::Database.load_all

require "active_record/fixtures"
class PrismaTest < Test::Unit::TestCase

  def insert_fixture(klass)
    fixture_file = Pathname.new(__FILE__).dirname + "fixtures/" + klass.table_name
    fix = Fixtures.new(klass.connection_pool.connection,
                       klass.table_name,
                       klass.name,
                       fixture_file) #, file_filter = DEFAULT_FILTER_RE)
    fix.insert_fixtures
  end

end
#require 'test_help'
=begin
class ActiveSupport::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true #false

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  # compare yaml, sort first to ensure matching if
  # some attribtues changed, this is not a 100%
  # test but should be enough for testing
  def assert_equal_yaml(yaml1, yaml2, text = nil)
    assert_equal yaml1.split("\n").sort, yaml2.split("\n").sort, text
  end

  def self.import_file(file)
    print "File #{file}.\n"
    Prisma.transform_file(file,"type=#{File.extname(file)[1..-1]}")

    source = Prisma::SourceDbMeta.new.prisma_initialize(:all, Prisma::FileRaw)
    source.transform
  end

  def file_info(filename)
    basename = Pathname.new(filename).basename.to_s
    unless basename =~ /([^\.]*)\.(.*)/
      g = Dir.glob(filename + ".*").reject {|f| f =~ /\~$/ or f=~/\..*\./}
      throw "More than one file found. (#{g.inspect})" if g.length > 1
      throw "File not found '#{filename + ".*"}'" if g.length == 0
      filename = g[0]
    end
    basename = Pathname.new(filename).basename.to_s
    throw "Malformed filename '#{filename}'" unless basename =~ /([^\.]*)\.(.*)/
    table_name, type = $1,$2
    table_class = Prisma.get_class_from_tablename(table_name)
    throw "Table '#{table_name}' not found." unless table_class
    
    ret = {:type => type, :table_class => table_class, :filename => filename}
  end

  def load_file(filename)
    fi = file_info(filename)
    table_class = fi[:table_class]

    case fi[:type]
    when "messages"
      Message.delete_all
      msgs = []
      for line in open(fi[:filename])
	# correct windows linefeeds
	line = line[0..-3] + "\n" if line.ends_with?("\r\n")

	parent = table_class.new
	message = Message.new.prisma_initialize(parent,line)
	message.save
	msgs.push message
      end
      return msgs
    when "archive"
      a = ArchiveMeta.new.prisma_initialize(fi[:filename])
      a.save            
      return a
    else
      throw "unknown type '#{type}'."
    end
  end

  def load_and_transform_file(filename, expected_message_count = 0)
    fi = file_info(filename)
    Message.delete_all
    fi[:table_class].delete_all

    ret = load_file(filename)
    Prisma.transform_messages
    if Message.count > 0
      Message.find(:all).each {|m|
	p m.msg
      }
      print "Found still #{Message.count} messages.\n"
    end
    assert_equal expected_message_count, Message.count
  end

  # from http://wiki.rubyonrails.org/rails/pages/HowtoUseMultipleDatabasesWithFixtures
  
  cattr_accessor :classes_cache
  #class cache for storing already founded classes from models
  @@classes_cache = {}

  def table_names_and_classes(table_names)
    table_names = table_names.flatten.collect{|t| t.to_s}
    tables = table_names.map {|table_name|
      unless @@classes_cache[table_name].nil?
        klass = @@classes_cache[table_name]
      else
        begin 
          #try to find class name from table name
          klass = eval(table_name.classify)
        rescue
          #go to model directory, run through all models and search for table name
          classes = Dir.entries(RAILS_ROOT + "/app/models").select{|d| d.include?(".rb")}.collect{|f| File.basename(f, ".rb").classify}
          klass_names = classes.select{|f| (eval("#{f}.table_name") rescue false)==table_name }
          klass_name = klass_names.blank? ? table_name.classify : klass_names.first
          klass = eval(klass_name)
        end
        @@classes_cache[table_name] = klass
      end
      [table_name, klass]
    }
  end


  def load_user_fixtures(*table_names)
    tables = table_names_and_classes(table_names)

    # clear tables
    tables.each {|table_name,klass|
      klass.delete_all
    }

    tables.each {|table_name, klass|
      fs = Dir.glob(File.dirname(__FILE__) + "/fixtures_*").map {|f_path|
	fix = Fixtures.new(klass.connection, 
			   klass.table_name,
			   klass.name,
			   f_path + "/" + klass.table_name) #, file_filter = DEFAULT_FILTER_RE)
	fix.insert_fixtures
      }
    }

    # check if fixtures are loaded
    tables.each {|table_name,klass|
      raise "Fixtures of class #{klass.name} not loaded"if klass.count == 0
    }
  end
    

  #  CHART_YAML =  "--- !ruby/object:Chart \nattributes: \n  time_range: \"2008-04-09\"\n  name: Date Test Bars\n  chart_type: bars\n  id: \"1\"\n  description: For date report testing\n  height: \"300\"\n  order_by: \n  aggregation_column: date\n  column1: date\n  width: \"300\"\n  aggregation_function: COUNT\n  column2: time\n"
  #  CHART_YAML =  "--- !ruby/object:Chart \nattributes: \n  column3: \n  time_range: \"2008-04-09\"\n  name: Date Test Bars\n  chart_type: bars\n  id: \"1\"\n  description: For date report testing\n  stacked: \"0\"\n  max_values: \"45\"\n  height: \"300\"\n  order_by: \n  aggregation_column: date\n  column1: date\n  aggregation_function: COUNT\n  width: \"300\"\n  column2: time\n"
  CHART_YAML =  "--- !ruby/object:Chart \nattributes: \n  column3: \n  time_range: \"2008-04-09\"\n  name: Date Test Bars\n  flipped: f\n  chart_type: bars\n  id: \"1\"\n  description: For date report testing\n  stacked: f\n  max_values: \"45\"\n  height: \"300\"\n  order_by: \n  aggregation_column: date\n  column1: date\n  width: \"300\"\n  aggregation_function: COUNT\n  column2: time\n"
  
  CHART_QUERY = "SELECT date, time, COUNT(date) AS data FROM application_logs WHERE `date` = '2008-04-09'  GROUP BY time, date ORDER BY date, time"
  
  CHART_RENDER_OPTIONS = {:conditions => "1=1", :datasource => ApplicationLog}
  
  #  CHART_AFTER_RENDER_YAML = "--- !ruby/object:Chart \nattributes: \n  time_range: \"2008-04-09\"\n  name: Date Test Bars\n  chart_type: bars\n  id: \"1\"\n  description: For date report testing\n  height: \"300\"\n  order_by: \n  aggregation_column: date\n  column1: date\n  width: \"300\"\n  aggregation_function: COUNT\n  column2: time\nexternal_link: http://localhost:3001/alois/table/application_logs/chart_click?default_filter=%60date%60+%3D+%272008-04-09%27++AND+1%3D1&\noption_conditions: 1=1\ntable_name: application_logs\n"
  #  CHART_AFTER_RENDER_YAML = "--- !ruby/object:Chart \nattributes: \n  column3: \n  time_range: \"2008-04-09\"\n  name: Date Test Bars\n  chart_type: bars\n  id: \"1\"\n  description: For date report testing\n  stacked: \"0\"\n  max_values: \"45\"\n  height: \"300\"\n  order_by: \n  aggregation_column: date\n  column1: date\n  aggregation_function: COUNT\n  width: \"300\"\n  column2: time\nexternal_link: https://localhost:3001/alois/table/application_logs/chart_click?default_filter=%60date%60+%3D+%272008-04-09%27++AND+1%3D1&\noption_conditions: 1=1\ntable_name: application_logs\n"  
  CHART_AFTER_RENDER_YAML = "--- !ruby/object:Chart \nattributes: \n  column3: \n  time_range: \"2008-04-09\"\n  name: Date Test Bars\n  flipped: f\n  chart_type: bars\n  id: \"1\"\n  description: For date report testing\n  stacked: f\n  max_values: \"45\"\n  height: \"300\"\n  order_by: \n  aggregation_column: date\n  column1: date\n  width: \"300\"\n  aggregation_function: COUNT\n  column2: time\nexternal_link: https://localhost:3001/alois/table/application_logs/chart_click?default_filter=%60date%60+%3D+%272008-04-09%27++AND+1%3D1&\noption_conditions: 1=1\ntable_name: application_logs\n"


  def self.test_chart
    c = Chart.find(:first)
    c.datasource = ApplicationLog
    c
  end

  def save_email(mail, name)
    file = "#{RAILS_ROOT}/tmp/#{name}.eml"
    open("#{file}","w") {|f| f.write(mail.encoded)}
    print "Email saved to '#{file}'.\n"
    if false
      print "Starting kmail..."
      system " kmail --view '#{file}'\n"    
      print "done\n"
    end
    print "Check it in thunderbird.\n"
    print "/!\\ Thunderbird does not display inline pictures if\n"
    print "/!\\ the message is saved on disk."
  end
  def email_body(part)
    # or something with that? TMail::Base64.folding_encode(body)
    (part.body + part.parts.map {|p| email_body(p)}.join).gsub("=\n","").gsub("=3D","=")
  end

  def check_links_in_email(mail)
    assert !(mail.body =~ /href=\"(\/[^\"]*)\"/), "Link without domain found '#{$1}'! (href=\"/), maybe you forgegotten option , :only_path => false in link_to."
  end
  
  def assert_tidy_html
    tidy_command = "tidy -errors -quiet"
    open("|#{tidy_command} 2>&1 > /dev/null","w") {|f|
      f.write(@response.body)
    }
    if $?.to_i != 0
      @response.body.split("\n").each_with_index{|l,i|
	print "#{(i+1).to_s.rjust(3)}: #{l}\n"
      }
    end
    open("|#{tidy_command} > /dev/null","w") {|f|
      f.write(@response.body)
    }
    assert_equal 0,$?.to_i,"Tidy is not happy with the html output."
  end

end
=end
