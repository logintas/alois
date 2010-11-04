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
require 'performance_test_help'

# Profiling results for each test method are written to tmp/performance.
# kcachegrind can be used to analyze tree
class PrismaTest < ActionController::PerformanceTest
  def setup
    SyslogdRaw.delete_all
    kern = true
    if kern
      date_time = DateTime.now
      date = date_time.strftime("%F")
      time = date_time.strftime("%T")
      500.times {
        SyslogdRaw.create(:ip => "127.0.0.111",
                          :host => "testhost",
                          :facility => "kern",
                          :priority => "info",
                          :level => "info",
                          :tag => "",
                          :date => date,
                          :time => time,
                          :program => "Alois Random",
                          :msg => "kernel: [13049117.712831] Swl:FORWARD:1:REJECT:IN=vpnbr100 OUT=eth1 PHYSIN=eth2 SRC=192.168.100.111 DST=130.117.190.134 LEN=52 TOS=0x00 PREC=0x00 TTL=127 ID=14019 DF PROTO=TCP SPT=63965 DPT=80 WINDOW=8192 RES=0x00 SYN URGP=0")
      }
    else
      Prisma.generate_random_raws(500)      
    end

  end

  def test_performance

    assert 500, SyslogdRaw.count

#    time = Benchmark.measure {
      Prisma.transform_all_raws(SyslogdRaw)
#    }.real
#    assert_equal 0, SyslogdRaw.count
    # Genuine Intel(R) CPU           T2400  @ 1.83GHz it took about 6 seconds
#    assert time < 15, "Should not take more than 15 seconds. It was #{time}."
#    print "Time OK: #{time}\n"

    # 2010-09-16, in vbox guest
    # PrismaTest#test_performance (27.30 sec warmup)
    #        process_time: 43.15 sec

    assert 0, SyslogdRaw.count
  end
end
