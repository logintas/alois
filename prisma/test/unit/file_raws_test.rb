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

class PrismaTest < ActiveSupport::TestCase
  ARCH_DIR = "#{RAILS_ROOT}/tmp/archive/test/prisma/"
  LOG_FILE = "#{RAILS_ROOT}/log/FileRaw.log"
  
  def setup
    [FileRaw, SourceDbMeta,FileMeta,PureMeta,LogMeta,Message,CronMeta].each {|k|
      k.delete_all
    }
    load_user_fixtures :file_raws
    FileUtils.remove_dir(ARCH_DIR) if File.exist?(ARCH_DIR)
    File.delete(LOG_FILE) if File.exist?(LOG_FILE)
  end

  def test_file_size
    FileRaw.delete_all
    kbytes = 1024
    file = "/tmp/alois-big-test-file.log"
    system("dd if=/dev/urandom of=#{file} bs=1024 count=#{kbytes} 2>/dev/null")
    Prisma.transform_file(file, :type => "log")
    assert_equal 1, FileRaw.count
    raw = FileRaw.find(:first)
    assert_equal 1024 * kbytes, raw["msg"].length
    assert_equal 1024 * kbytes, raw.msg.length
  end

  def test_file_import
    assert_equal 1, FileRaw.count()
    assert_equal 0, FileMeta.count()
    assert_equal 0, SourceDbMeta.count()
    
    $alois_disabled_transaction = true
    Prisma.transform_all_raws(FileRaw)
    
    assert_equal 0, FileRaw.count()
    #p SourceDbMeta.find(:all).each {|s| p s}
#    p SourceDbMeta.connection.select_value("SELECT count(*) FROM source_db_metas")

    assert_equal 1, SourceDbMeta.count()
    assert_equal 1, FileMeta.count()
    assert_equal 6, PureMeta.count()
    assert_equal 6, LogMeta.count()
    assert_equal 5, Message.count()
    assert_equal 5, Message.count(:conditions => "meta_type_name = 'Prisma::LogMeta'")

    m = CronMeta.find(:first)
    5.times {
      assert m
      m = m.parent
    }
    assert m.nil?
    
    
#    assert_equal 1, ApacheFileMeta.count()
#    assert_equal 100, ApacheMeta.count()
  end
end
