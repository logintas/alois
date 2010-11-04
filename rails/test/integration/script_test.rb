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

class ScriptTest < ActiveSupport::TestCase
  
  ARCH_DIR = "#{RAILS_ROOT}/tmp/archive/test/prisma/"

  def ttest_compress_archive_syslog
    FileUtils.remove_dir(ARCH_DIR) if File.exist?(ARCH_DIR)

    archivator = Archivator.new($archive_pattern, SyslogdRaw)
    archivator.archivate(SyslogdRaw.new(:date => "2007-02-02", :time => "20:00:00"))
    
    assert File.exist?("#{ARCH_DIR}syslogd_raws/#{Time.now.strftime("%F")}/2007-02-02.arch")
    FileUtils.move("#{ARCH_DIR}syslogd_raws/#{Time.now.strftime("%F")}","#{ARCH_DIR}syslogd_raws/2007-01-01")
    assert File.exist?("#{ARCH_DIR}syslogd_raws/2007-01-01/2007-02-02.arch")    

    archivator = Archivator.new($archive_pattern, SyslogdRaw)
    archivator.archivate(SyslogdRaw.new(:date => "2007-02-02", :time => "20:00:00"))

    assert File.exist?("#{ARCH_DIR}syslogd_raws/#{Time.now.strftime("%F")}/2007-02-02.arch")

    ENV['RAILS_ENV'] = "test"
    system("script/compress_archives")

    assert File.exist?("#{ARCH_DIR}syslogd_raws/#{Time.now.strftime("%F")}/2007-02-02.arch")
    assert !File.exist?("#{ARCH_DIR}syslogd_raws/2007-01-01/2007-02-02.arch")
    assert File.exist?("#{ARCH_DIR}syslogd_raws/2007-01-01/2007-02-02.arch.gz")
  end

  def test_compress_archive_file
    FileUtils.remove_dir(ARCH_DIR) if File.exist?(ARCH_DIR)

    archivator = Archivator.new($archive_pattern, FileRaw)
    archivator.archivate(FileRaw.new())
    
    assert File.exist?("#{ARCH_DIR}file_raws/#{Time.now.strftime("%F")}/#{Time.now.strftime("%F")}.arch")
    FileUtils.move("#{ARCH_DIR}file_raws/#{Time.now.strftime("%F")}","#{ARCH_DIR}file_raws/2007-01-01")
    FileUtils.move("#{ARCH_DIR}file_raws/2007-01-01/#{Time.now.strftime("%F")}.arch","#{ARCH_DIR}file_raws/2007-01-01/2007-02-03.arch")    
    assert File.exist?("#{ARCH_DIR}file_raws/2007-01-01/2007-02-03.arch")

    archivator = Archivator.new($archive_pattern, FileRaw)
    archivator.archivate(FileRaw.new())
    FileUtils.move("#{ARCH_DIR}file_raws/#{Time.now.strftime("%F")}/#{Time.now.strftime("%F")}.arch","#{ARCH_DIR}file_raws/#{Time.now.strftime("%F")}/2007-02-03.arch")

    assert File.exist?("#{ARCH_DIR}file_raws/#{Time.now.strftime("%F")}/2007-02-03.arch")

    ENV['RAILS_ENV'] = "test"
    system("script/compress_archives")

    assert File.exist?("#{ARCH_DIR}file_raws/#{Time.now.strftime("%F")}/2007-02-03.arch")
    assert !File.exist?("#{ARCH_DIR}file_raws/2007-01-01/2007-02-03.arch")
    assert File.exist?("#{ARCH_DIR}file_raws/2007-01-01/2007-02-03.arch.gz")
  end

end
