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
require 'alarm_mailer'

class AlarmMailerTest < ActiveSupport::TestCase
  fixtures :alarms, :sentinels
  # using howto on:
  # http://manuals.rubyonrails.com/read/chapter/64
  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @alarm = Alarm.find(1)
  end

  def test_simple
    response = AlarmMailer.create_simple(["test@logintas.com","test2@logintas.com"],@alarm)
    check_links_in_email(response)
    body = email_body(response)
    save_email(response,"alarm_simple")

    assert_match /Alarm Some sentinel \(warning\)$/, response.subject
    # plaintextlink
    assert_match /Link: https:\/\/localhost:3001\/alois\/alarms\/show\/1/, body
    # htmllink

    assert_match /<a href=\"https:\/\/localhost:3001\/alois\/alarms\/show\/1\" style=\"[^\"]*\">Alarm \#1<\/a>/, body

    #@alarm = Alarm.find(1)
    #AlarmMailer.create_simple(["flavio.pellanda@logintas.ch"],@alarm)
    
  end

end
