# Be sure to restart your server when you modify this file
# init counters
$expression_count = 0

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# define home for rubyforge gem (needs one)
ENV["HOME"] ||= "/tmp/"

require Pathname.new(RAILS_ROOT) + "config/default_config.rb"
Rails::Initializer.run do |config|
  load_config(config)
end

# TODO: maybe this is obsolete now
#require "fix_activerecrod_base_inspect_bug"
require Pathname.new(RAILS_ROOT) + "config/default_environment.rb"

# do
#  if filename
# instead of
#  if content_disposition == "attachment"
require "action_mailer-patch.rb"

## Comment this out if prisma daemon sould
## be runned
$do_not_run_prisma = false
 
## Mail konfiguration for sentinels

## if not defined "localhost" is used
## $email_smtp_server = "smtp.example.com"

## sender address for sentinel mails
$email_sender_address = "Alois Test <alois-test@logintas.com>"

## sender address for sentinel mails
$email_default_subject = "Alois-Test - Prisma ALERT"

## how the logs are archived. The following
## values will be replaced:
##  %c: with the class name (Prisma::XyzRaw)
##  %t: with the table name (xyz_raw)
##  %i: with the incoming date (the current system date)
##  %d: with the log date (the date contained by in the raw class)
$archive_pattern =  "#{RAILS_ROOT}/tmp/archive/#{RAILS_ENV}/prisma/%t/%i/%d.arch"

## how the reports are archived. The following
## values will be replaced:
##  %n: with the name of the report
##  %d: with the date of creation (YYYY-MM-DD)
##  %t: with the time of creation (HH:MM:SS)
## The value must give a Directory
$report_archive_pattern = "#{RAILS_ROOT}/tmp/archive/#{RAILS_ENV}/reports/%n/%d/%t"

## how the alarms are archived. The following
## values will be replaced:
##  %i: with the id of the alarm
##  %d: with the date of creation (YYYY-MM-DD)
##  %t: with the time of creation (HH:MM:SS)
## The value must give a Directory
$alarm_archive_pattern = "#{RAILS_ROOT}/tmp/archive/#{RAILS_ENV}/alarms/%d/%i"

## alois installation name, for email subjects etc.
$installation_name = "Alois TESTING on #{Socket.gethostname}"

$group_map = {
  "admin" => "admin"
}

# 1tier or 3tier.
# 1tier: all components installed on localhost
# 3tier: partitioning of components on 3 hosts: (reporting,prisma) (alois-db) (sink-db,sink)
$installation_schema = "1tier"
