$themes = []
if !defined?(RAILS_ENV) or RAILS_ENV == "production"
  # will be substitutet at package building
  ALOIS_VERSION = "###VERSION###" unless defined?(ALOIS_VERSION)
else
  ALOIS_VERSION = "#{RAILS_ENV} version" unless defined?(ALOIS_VERSION)
end

require "alois/utils"
require 'pathname'
require 'alois/date_time_enhance'
require 'mysql_adapter_extensions'
require 'dummy_class_extension'
require 'will_paginate'
require 'inline_attachment'
require 'awesome_email_fix'

ActionView::Helpers::AssetTagHelper.register_javascript_include_default(
  "prototype","effects","dragdrop","controls","application")

begin
  require "ruport/acts_as_reportable"
rescue LoadError
  print "Unable to load acts_as_reportable: #{$!}\n"
end
ActiveRecord::Base.acts_as_reportable if ActiveRecord::Base.respond_to?(:acts_as_reportable)

# register alois conneciton
begin
  attr = {"name" => "alois"}.update(ActiveRecord::Base.configurations[RAILS_ENV])
  attr.delete("reconnect")                                    
  alois_conn = Connection.new(attr)
  alois_conn.pool = ActiveRecord::Base.connection_pool
  Connection.register(alois_conn)
rescue
  $log.warn("Could not load alois connection: #{alois_conn}")
end

Pathname.glob("/var/lib/prisma/archive/*_raws*").each {|f|
  if File.ftype(f) == "file"
    msg = "PLEASE MOVE THE CONTENT OF OLD ARCHIVE /var/lib/prisma/archive/* TO ANOTHER DIRECTORY\nEG TO: /var/lib/prisma/archive/old\n  # mkdir /var/lib/prisma/archive/old\n  # mv /var/lib/prisma/archive/*raws* /var/lib/prisma/archive/old"
    print msg + "\n"
    $log.error(msg)
    throw msg
  end
}

########################################
# Appliances
#
# Define here which appliances should
# be processed
########################################
#require "ruport"
require "ip_address"
#require "mysql_retry_lost_connection"
ActiveRecord::SchemaDumper.ignore_tables = [/view_.*/]

## How many seconds prisma should wait if there
## is no record to process
$default_waiting_time = 2

## How many records per query should be processed
$default_count = 100

## niceness (-10 higher priority, 10 lower priority)
$default_niceness = 0

## default archive time. After this time the logs will be deleted
## in archive and in the database
$delete_logs_before = 1.year.ago

## how the logs are archived. The following
## values will be replaced:
##  %c: with the class name (Prisma::XyzRaw)
##  %t: with the table name (xyz_raw)
##  %i: with the incoming date (the current system date)
##  %d: with the log date (the date contained by in the raw class)
## The value must give a filename with ending arch.
$archive_pattern =  "/var/lib/prisma/archive/%t/%i/%d.arch"

## how the reports are archived. The following
## values will be replaced:
##  %n: with the name of the report
##  %d: with the date of creation (YYYY-MM-DD)
##  %t: with the time of creation (HH:MM:SS)
## The value must give a Directory
$report_archive_pattern = "/var/lib/alois/archive/reports/%d/%n/%t"

## how the alarms are archived. The following
## values will be replaced:
##  %i: with the id of the alarm
##  %d: with the date of creation (YYYY-MM-DD)
##  %t: with the time of creation (HH:MM:SS)
## The value must give a Directory
$alarm_archive_pattern = "/var/lib/alois/archive/alarms/%d/%i"

## developper email address for exceptions
$developper_email = "flavio.pellanda@logintas.ch"

## root url for email links
$root_url ||= "https://#{Socket.gethostname}/alois/"

## default umask (0007 group an user can do everything)
File.umask(0007)

## commit this amount of operations together
$transaction_bundle_amount ||= 500

begin
# require 'home_run'
rescue
 $log.warn("Could not load home_run, however this is not necessary but faster")
end
