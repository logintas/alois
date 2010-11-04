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
require 'report_mailer'

class ReportMailerTest < ActionMailer::TestCase
  # because some create view statements will appear
  self.use_transactional_fixtures = false

  fixtures :reports,:report_templates,
    :charts_report_templates, :report_templates_tables, :tables, :charts
  # using howto on:
  # http://manuals.rubyonrails.com/read/chapter/64

  def test_simple
    @report = Report.find(1)
    
    # do not add csv cause the chart data is not available
    # testing these functions in functional/report_test
    response = ReportMailer.create_simple(["test@logintas.com","test2@logintas.com"],@report, {:add_csv => false})
    check_links_in_email(response)
    save_email(response,"report_simple")
    assert_match /Report Report One$/, response.subject
    
    body = email_body(response)
    # plaintextlink
    assert_match /Link: https:\/\/localhost:3001\/alois\/reports\/show\/1/, body
    assert_match /<a href=\"https:\/\/localhost:3001\/alois\/reports\/show\/\d+\" style=\"[^\"]*\">Report \#\d+<\/a>/, body
  end
  
  def test_normal
    #    @report = Report.find(1)
    @report = Report.generate(ReportTemplate.find(1),"test",:datasource => View.find(1))
    response = ReportMailer.create_normal(["test@logintas.com","test2@logintas.com"],@report)
    check_links_in_email(response)
    save_email(response,"report_normal")

    assert_match /Report DateTest for For always generating records$/, response.subject

    body = email_body(response)

    # plaintextlink

    assert_match /Link: https:\/\/localhost:3001\/alois\/reports\/show\/\d+/, body
    # htmllink
    assert_match /<a href=\"https:\/\/localhost:3001\/alois\/reports\/show\/\d+\" style=\"[^\"]*\">Report \#\d+<\/a>/, body

  end

end
