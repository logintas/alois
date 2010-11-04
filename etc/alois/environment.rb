# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
Object.send(:remove_const, :RAILS_ENV) if defined?(RAILS_ENV)
RAILS_ENV = 'production'

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
 
## Mail konfiguration for sentinels

## if not defined "localhost" is used
## $email_smtp_server = "smtp.example.com"

## sender address for sentinel mails
$email_sender_address = "Alois <alois@logintas.com>"

## alois installation name, for email subjects etc.
$installation_name = "Alois DEFAULT NAME"

# user admin has role admin
# USER => ROLE
$group_map = {
  "admin" => "admin",
}

# 1tier or 3tier.
# 1tier: all components installed on localhost
# 3tier: partitioning of components on 3 hosts: (reporting,prisma) (alois-db) (sink-db,sink)
$installation_schema = "1tier"
