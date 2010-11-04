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

class ReportTest < ActiveSupport::TestCase
  # because some create view statements will appear
  self.use_transactional_fixtures = false

  fixtures :reports,:report_templates, :charts_report_templates,
    :alarms, :sentinels

  def setup
    ActionMailer::Base.deliveries = []
  end

  def test_no_template_given
    sentinel = Sentinel.find(1)
    assert sentinel
    sentinel.report_template = nil    
    assert sentinel.view.table.count > 0
    sentinel.action = :alarm_and_report
    sentinel.save

    assert sentinel.is_alarm?
    
    rt_count = ReportTemplate.count
    alarm_count = Alarm.count
    report_count = Report.count

    BaseMailer.expecting_mail
    sentinel.process
    assert sentinel.process_errors
    assert_equal 1, sentinel.process_errors.length, sentinel.process_errors.inspect
    assert_equal 0, BaseMailer.not_delivered_mails_count
    assert BaseMailer.latest_mail.to_s =~ /No report_template given./
  end
  
  def test_report
    my_test_report
  end

  def test_report_do_not_use_mysql_view
    view = Sentinel.find(3).view
    view.do_not_use_view_for_query = true
    view.save
    my_test_report
  end

  def my_test_report
    alarm_count = Alarm.count
    report_count = Report.count

    SyslogdRaw.delete_all
    LogMeta.delete_all
    SyslogdMeta.delete_all

    sentinel = Sentinel.find(3)

    # run disabled sentinel
    assert_equal :disabled, sentinel.action_name
    err = assert_raise RuntimeError do
      sentinel.process
    end
    assert_equal "This sentinel is disabled.",err.message

    # run sentinel for yesterday to
    # check that no report will be generated
    sentinel.action = :alarm_and_report
    assert_equal :alarm_and_report, sentinel.action_name
    
    alarm,report = sentinel.process
    assert_nil sentinel.process_errors, sentinel.process_errors
    assert alarm.nil?
    assert report.nil?
    assert_equal alarm_count, Alarm.count
    assert_equal report_count, Report.count

    # add new logs to syslogd_raws from
    #  2 days ago
    #  yesterday
    #  today
    days_count = {"2 days ago" => 11, 
      "yesterday" => 5, 
      "today" => 12}

    days_count.each {|date, count|
      
      beginning,ending = rand(2),rand(2)
      begin_date,end_date = "beginning #{date}".to_time,"ending #{date}".to_time
      range = (begin_date..end_date).to_a

      beginning.times{ SyslogdRaw.create_random_test_message(begin_date) }
      ending.times{ SyslogdRaw.create_random_test_message(end_date) }
      (count-beginning-ending).times { SyslogdRaw.create_random_test_message(range.rand) }
    }

    total_logs = days_count.sum(&:last)
    assert_equal total_logs, SyslogdRaw.count
        
    # run prisma
    Prisma::Transform.transform_all_raws(SyslogdRaw)
    assert_equal total_logs, LogMeta.count
    
    # to reset cached count
    sentinel = Sentinel.find(3)
    # run sentinel for yesterday to
    # check that no report will be generated
    sentinel.action = :alarm_and_report
    assert_equal :alarm_and_report, sentinel.action_name

    # also check email delivery
    sentinel.send_mail = true
    sentinel.mail_to = "flavio.pellanda@logintas.ch"

    # run sentinel for yesterday
    assert_equal :error,sentinel.alarm_level_name
    assert_equal :alarm_and_report, sentinel.action_name
    assert sentinel.date_condition
    assert_equal days_count["yesterday"],sentinel.count
    assert_equal 0, sentinel.threshold
    assert sentinel.is_alarm?, "Sentinel says its not an alarm."
    assert sentinel.report_template

    BaseMailer.expecting_mail(2)
    alarm,report = sentinel.process
    assert_nil sentinel.process_errors, sentinel.process_errors
    assert alarm
    # TODO: by a bug the text field only works
    # if the alarm is reloaded
    alarm = Alarm.find(alarm.id)
    assert alarm.text =~ /original_text/
    assert report
    assert_equal sentinel.alarm_level, alarm.alarm_level

    # check that a new report is generated
    assert_equal report_count + 1, Report.count

    # check that a new alarm was generated
    assert_equal alarm_count + 1, Alarm.count
    
    # check that email was delivered
    assert_equal 0, BaseMailer.not_delivered_mails_count
    assert_equal "#{$installation_name} - Report Testing log metas statistics for Alois-Basis log_metas with syslogd_metas and messages", BaseMailer.deliveries[-1].subject,
      "Not the right mail was delivered: #{BaseMailer.deliveries[-1].subject}"
    assert_equal "#{$installation_name} - Alarm For testing yesterday (error)", BaseMailer.deliveries[-2].subject,
      "Not the right mail was delivered: #{BaseMailer.deliveries[-2].subject}"
    assert BaseMailer.deliveries[-2].to_s =~ /Alarm ocurred/

    # disable report
    sentinel.action = :alarm

    # run sentinel for yesterday again
    BaseMailer.expecting_mail
    alarm,report = sentinel.process
    assert_nil sentinel.process_errors, sentinel.process_errors
    assert alarm
    assert report.nil?
    assert_equal sentinel.alarm_level, alarm.alarm_level

    # check that a new alarm was generated
    assert_equal alarm_count + 2, Alarm.count

    # check that a no new report is generated
    assert_equal report_count + 1, Report.count

    # check that email was delivered
    assert_equal 0, BaseMailer.not_delivered_mails_count
    assert_equal "#{$installation_name} - Alarm For testing yesterday (error)", BaseMailer.latest_mail.subject,
      "Not the right mail was delivered: #{BaseMailer.latest_mail.to_s}"
    assert BaseMailer.latest_mail.to_s =~ /Alarm ocurred/

    # disable alarm
    sentinel.action = :report

    # run sentinel for yesterday again
    BaseMailer.expecting_mail
    alarm,report = sentinel.process
    assert_nil sentinel.process_errors, sentinel.process_errors
    assert alarm.nil?
    assert report

    # check that a new alarm was generated
    assert_equal alarm_count + 2, Alarm.count

    # check that a no new report is generated
    assert_equal report_count + 2, Report.count

    # check that email was delivered
    assert_equal 0, BaseMailer.not_delivered_mails_count
    assert_equal "#{$installation_name} - Report Testing log metas statistics for Alois-Basis log_metas with syslogd_metas and messages", BaseMailer.latest_mail.subject,
      "Not the right mail was delivered: #{BaseMailer.latest_mail.to_s}"

    # check that csv is attached
    assert !( BaseMailer.latest_mail.to_s =~ /Alarm ocurred/)
    assert_report
    assert_csv

    BaseMailer.expecting_mail
    sentinel.include_csv_in_email = false
    sentinel.include_report_in_email = false
    alarm,report = sentinel.process
    assert_equal 0, BaseMailer.not_delivered_mails_count

    # check that csv is not attached
    assert_no_csv
    assert_no_report

    BaseMailer.expecting_mail
    sentinel.include_csv_in_email = true
    sentinel.include_report_in_email = false
    alarm,report = sentinel.process
    assert_equal 0, BaseMailer.not_delivered_mails_count

    assert_csv
    assert_no_report

    BaseMailer.expecting_mail
    sentinel.include_csv_in_email = false
    sentinel.include_report_in_email = true
    alarm,report = sentinel.process
    assert_equal 0, BaseMailer.not_delivered_mails_count

    assert_no_csv
    assert_report
  end

  def assert_attachment(regex = nil)
    assert BaseMailer.latest_mail.attachments.length > 0, "No attachment"
  end

  def assert_csv
    assert_equal 1,BaseMailer.latest_mail.attachments.select {|a| a.original_filename == "csv_datas.zip"}.length {
      (save_email(BaseMailer.latest_mail, "error_mail");"Csv not found. (#{BaseMailer.latest_mail.attachments.map {|a| a.original_filename}.inspect})")}
  end
  
  def assert_no_csv
    assert_equal 0,BaseMailer.latest_mail.attachments.select {|a| a.original_filename == "csv_datas.zip"}.length {
      (save_email(BaseMailer.latest_mail, "error_mail");"Csv found. (#{BaseMailer.latest_mail.attachments.map {|a| a.original_filename}.inspect})")}
  end
  
  def assert_report
    assert 0 < BaseMailer.latest_mail.attachments.select {|a| a.original_filename =~ /chart_/}.length {
      (save_email(BaseMailer.latest_mail, "error_mail");"No Charts attached. (#{BaseMailer.latest_mail.attachments.map {|a| a.original_filename}.inspect})")}
  end

  def assert_no_report
    assert_equal 0, BaseMailer.latest_mail.attachments.select {|a| a.original_filename =~ /chart_/}.length {
      (save_email(BaseMailer.latest_mail, "error_mail");"Charts attached. (#{BaseMailer.latest_mail.attachments.map {|a| a.original_filename}.inspect})")}
  end
end

    

    
    

