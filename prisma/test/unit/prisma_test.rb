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

require File.dirname(__FILE__) + '/../test_helper'

class PrismaTest < Test::Unit::TestCase
  # because some transactions are needed in this test
  
  LOG_FILE = PRISMA_LOG_DIR + "SyslogdRaw.log"

  def setup
    SyslogdRaw.delete_all
    FileRaw.delete_all
#    load_user_fixtures :syslogd_raws
    FileUtils.remove_dir(PRISMA_ARCHIVE) if PRISMA_ARCHIVE.exist?
    File.delete(LOG_FILE) if File.exist?(LOG_FILE)
  end

  GENERATE_OUTPUT = false

  def test_signal_term
    # generate random data to process
    p "Generate data" if GENERATE_OUTPUT 
    Prisma::Util.generate_random_raws(200)
    p "done" if GENERATE_OUTPUT 
    count = SyslogdRaw.count
# fp was 200
    assert count >= 20, "No test data generated... ??"
    
    pid = fork do
      exec("bin/prisma start SyslogdRaw -f -c 10 -v")
    end
    
    p "prisma started" if GENERATE_OUTPUT 

    start_timeout = 20
    begin      
      # Wait until prisma started
      Timeout.timeout(start_timeout) {
        new_count = SyslogdRaw.count
	while new_count == count
          new_count = SyslogdRaw.count
	  print "Wait for prisma start #{new_count} == #{count}.\n" if GENERATE_OUTPUT 
	  sleep 1
	end
      }
    rescue Timeout::Error
      # kill all prisma processes
      system("pkill -KILL prisma")
      assert false, "Prisma had more than #{start_timeout} seconds to start."
    end
    p "OK, started, so kill" if GENERATE_OUTPUT 

    # ok, prisma is running now. Sending signal term
    Process.kill("TERM", pid)

    kill_timeout = 3
    begin
      # Prisma should return in one second
      Timeout.timeout(kill_timeout) {
	p "going to wait" if GENERATE_OUTPUT 
	Process.waitpid(pid)
	p "Returned" if GENERATE_OUTPUT 
      }
    rescue Timeout::Error
      p "timeout" if GENERATE_OUTPUT 
      # kill all prisma processes
      system("pkill -KILL prisma")
      assert false, "Prisma had more than #{kill_timeout} second(s)."
    end

    p "check kill prisma" if GENERATE_OUTPUT 
    assert(!system("pkill -KILL prisma"), "Oups, there were still prisma processes running.")

    p "assert last" if GENERATE_OUTPUT 
    # ok prisma returned normally
    assert(SyslogdRaw.count > 0, "Prisma processed all raws. Increment raw count. Test not evident.")

    assert File.exist?(LOG_FILE), "#{LOG_FILE} was not written."
    
  end

  def find_original(meta, orig)
    assert meta
    assert (found = meta.original)
    assert found.class != String, "Error finding orig: #{found}"
    assert_equal 1, found.length, "Original not found"
    assert_equal orig, found[0]
   
  end
  
  def test_find_original
    SyslogdRaw.delete_all
    SyslogdMeta.delete_all
    LogMeta.delete_all
    orig = SyslogdRaw.create_random_test_message    
    assert orig
    assert_equal Date.today.strftime("%F"), orig.date.strftime("%F")
    Prisma::Transform.transform_all_raws(SyslogdRaw)
    assert_equal 1, SyslogdMeta.count
    assert (sm = SyslogdMeta.find(:first))
    assert_equal orig.id, sm.queue_id
    assert sm.log_meta
    assert_equal Date.today.strftime("%F"), sm.log_meta.date.strftime("%F")

    # new way
    find_original(sm, orig)
    # from log_meta
    find_original(sm.children_a[0], orig)
    # old way
    sm.queue_id = nil
    find_original(sm, orig)      
  end


  def test_transform_queues    
    @raw_count = 80
    LogMeta.delete_all
    SourceDbMeta.delete_all
    SyslogdMeta.delete_all
    Message.delete_all
    $destroy_calls = 0

    assert_equal 0,SourceDbMeta.count
    assert_equal 0,SyslogdMeta.count
    assert_equal 0,LogMeta.count
    SyslogdRaw.delete_all
    FileRaw.delete_all

    insert_fixture(SyslogdRaw)

    assert_equal @raw_count,SyslogdRaw.count
    assert_equal 0,Message.count

    raws_to_reconstruct = [SyslogdRaw.find(:all)[0],SyslogdRaw.find(:all)[13],SyslogdRaw.find(:all)[-1]]

    assert @raw_count > 0    
    assert_equal SyslogdRaw.count, @raw_count

    ENV['LOG_OUTPUT'] = "stdout"
    rd, wr = IO.pipe
    pid = fork do
      STDOUT.reopen(wr)
      STDERR.reopen(wr)
      exec("bin/prisma start SyslogdRaw -f -vv")
    end
    
    counters = {
      :insert => /INSERT/,
      :delete => /DELETE/,
      :select => /SELECT/,
      :update => /UPDATE/,
      :commit => /COMMIT/,
      :show_tables => /SHOW TABLES/
    }
    $counts = {}
    counters.each {|key, regex| $counts[key] = 0}
    
    # set this to true uf you want to
    # see the output
    $print_all =  false
    $count_test = false
    listen_thread = Thread.fork do
      error = false
      l = ""
      while not l =~ /No new record in table syslogd_raws/
	l = "CHILD #{rd.readline}"	
	print "ERROR: #{l}\n" if l =~ /error/i and not l =~ /local jump/
	if (not (l =~ /source_db_metas/ or l =~ /Getting messages/)) and 
	    (l =~ /DELETE/ or l =~ /INSERT/ or l =~ /UPDATE/ or l=~ /SELECT/ or l=~ /COMMIT/ or l=~ /SHOW TABLES/)
	  counters.each {|key, regex| $counts[key] += 1 if l =~ regex  }
	  if l =~ /INSERT/ or l =~ / FROM .*_raws/ or l =~ /COMMIT/ or l =~ /schema_migrations/ or l =~/SHOW TABLES/
	    print "\e[5;36;1m\e[0m : #{l}" if $print_all
	  elsif l =~ /SELECT name/
            # sqlite only, do not count these selects
            $counts[:select] = $counts[:select] - 1
          else
	    print "\e[3;36;1mUNEXPECTED QUERY\e[0m : #{l}\n" 
	  end
	else
	    print "#{l}" if $print_all
	end
      end

      counters.each {|key, regex|
      }
      print "ERROR: #{error} DELETE: #{$counts[:delete]}(=1) INSERT: #{$counts[:insert]}(=#{@raw_count * 2}) UPDATE: #{$counts[:update]}(=0) SELECT: #{$counts[:select]}(<10) COMMIT: #{$counts[:commit]}(<20) SHOW TABLES: #{$counts[:show_tables]} (??)\n"

      if not error and
	  $counts[:delete] == 1 and 
	  $counts[:update] == 0 and 
	  $counts[:select] < 10 and 
	  $counts[:commit] < 20 and 
	  $counts[:insert] == @raw_count * 2
	$count_test = true
      end
    end

    begin
      Timeout.timeout(60) {
        listen_thread.join
      }
    rescue Timeout::Error
      Process.kill("KILL",pid)
      assert false, "Procesling logs had more than 60 seconds!"
    end        
    wr.close

    begin
      Timeout.timeout(10) {
        Process.kill("TERM",pid)
      }
    rescue Timeout::Error
      Process.kill("KILL",pid)
      assert false, "Primsa process not killed correctly"
    end        

    print "Waiting for prisma\n"
    Process.waitpid(pid)

    prisma_return = $?.exitstatus


#    Prisma::Database.check_connections

    # there may be only one delete (raw message delete query)
    assert_equal 0, prisma_return, "PRISMA did not return with exit 0"
    
    # no update inspite of sourcedb update may be done
    assert $count_test, "Query execution count tests failed. SEE CHECK OUTPUT"


    assert_equal 0, SyslogdRaw.count, "Not all raws deleted."
    assert_equal @raw_count, SyslogdMeta.count, "Syslogd metas not correct created."
    assert_equal @raw_count, Message.count

    # syslogd raw
    assert_equal 1,SourceDbMeta.count, "Source db metas not correct created.\n #{SourceDbMeta.find(:all).map(&:inspect).join("\n")}"

#    f = SourceDbMeta.find(:first, :conditions => ["raw_class_name = ?","FileRaw"])
    s = SourceDbMeta.find(:first, :conditions => ["raw_class_name = ?","SyslogdRaw"])
   
#    assert_equal f.raw_class, FileRaw
    assert_equal s.raw_class, SyslogdRaw
    
    i = 0
    s.children {|ch|
      i += 1
      assert_equal ch.class, SyslogdMeta      
    }
    assert_equal @raw_count, i

    # has archive been written?
    arch_file = PRISMA_ARCHIVE + "syslogd_raws/#{Date.today.to_s}/#{(Date.today - 1).to_s}.arch"
    assert arch_file.exist?, "Archfile '#{arch_file}' was not created!"
    
    # maybe include also file import test here?
    #    arch_file = "#{PRISMA_ARCHIVE}file_raws/#{Date.today.to_s}/#{(Date.today).to_s}.arch"
    #    assert File.exist?(arch_file), "Archfile '#{arch_file}' was not created!"

    # count lines
    i=0
    Dir.glob("#{PRISMA_ARCHIVE}/syslogd_raws/*/*").each {|fn|
      open(fn) {|f| f.each {|l| i += 1}
      }}
    assert_equal @raw_count, i, "Not all or duplicate logs archived."
      

    # Ensure that syslogd_raw can be refound in archive
    metas_to_reconstruct = [SyslogdMeta.find(:all)[0],SyslogdMeta.find(:all)[13],SyslogdMeta.find(:all)[-1]]
    metas_to_reconstruct.each_with_index { |meta,i|
      # assert_equal meta.original , raws_to_reconstruct[i]
      orgs = meta.original
      orgs.each {|o|
	print "#{o}\n"
      }
      assert_equal 1, orgs.length
      assert_equal orgs[0] , raws_to_reconstruct[i]
    }
    

    # Ensure that all records will be deleted
    p = LogMeta.find(:first)    
    m = Message.new.prisma_initialize(p,"DO NOT DELETE")
    assert m.meta_id, p.id
    m.meta_type_name = "TEST"
    m.save
    
    #ActiveRecord::Base.logger = Logger.new(STDOUT)

    predicted_deletes = SourceDbMeta.count + SourceDbMeta.find(:all).inject(0) {|s,m| s += m.children_recursive.length}
    Prisma::Database.delete_logs_before(:all,1.days.from_now.strftime("%F"))
    
    assert_equal 0,SyslogdRaw.count
    assert_equal 0,SourceDbMeta.count
    assert_equal 0,SyslogdMeta.count
    assert_equal 0,LogMeta.count
    assert_equal 1,Message.count    

    assert_equal 1 + 3 * @raw_count, $destroy_calls
    assert_equal predicted_deletes, $destroy_calls


    assert_equal 0,Dir.glob("#{PRISMA_ARCHIVE}syslogd_raws/*/*").length
  end

end
