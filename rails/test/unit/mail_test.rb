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

class ChartTest < ActiveSupport::TestCase

  def test_testing_mode
    assert 0, BaseMailer.not_delivered_mails_count

    err = assert_raise RuntimeError do
      BaseMailer.send_email(:text,"testing@logintas.ch","Test Email","none")
    end
    assert err.message =~ /No email expected..*/

    BaseMailer.expecting_mail
    assert 1, BaseMailer.not_delivered_mails_count
    BaseMailer.send_email(:text,"testing@logintas.ch","Test Email","none")
    assert 0, BaseMailer.not_delivered_mails_count

    err = assert_raise RuntimeError do
      BaseMailer.send_email(:text,"testing@logintas.ch","Test Email","none")
    end
    assert err.message =~ /No email expected..*/
    
    assert 1,BaseMailer.deliveries.length
  end

  def test_exception_mail
    BaseMailer.expecting_mail
    begin
      raise "Testingexception"
    rescue
      BaseMailer.send_exception($!)
    end
    assert_equal 0, BaseMailer.not_delivered_mails_count
    assert_equal "#{$installation_name} - Exception Alert", BaseMailer.latest_mail.subject
    assert BaseMailer.latest_mail.to_s =~ /mail_test.rb/
    assert BaseMailer.latest_mail.to_s =~ /Testingexception/

    BaseMailer.expecting_mail
    begin
      throw "Testingexception"
    rescue
      BaseMailer.send_exception($!)
    end
    assert_equal 0, BaseMailer.not_delivered_mails_count
    assert_equal "#{$installation_name} - Exception Alert", BaseMailer.latest_mail.subject
    assert BaseMailer.latest_mail.to_s =~ /mail_test.rb/
    assert BaseMailer.latest_mail.to_s =~ /Testingexception/
  end

end
