THEME_CONFIG_PATTERN = File.dirname(__FILE__) + "/../../../alois-theme-*/config.rb"
Pathname.glob(THEME_CONFIG_PATTERN).each {|config_file|
   require config_file
}

$selected_theme = $themes[0] if $themes and $themes.length > 0
include $selected_theme if $selected_theme

def load_config(config)
  config.logger = $log if $log

  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  
  # Specify gems that this application depends on and have them installed with rake gems:install
  
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"
  if ENV["GEM_HOME"]
    config.gem "hpricot"
    config.gem "ruport" #, :version => "1.2.0"
    config.gem "acts_as_reportable", :lib => "ruport"
    config.gem "mysql", :version => "2.7"
    config.gem "hoe" #, :version => "1.7.0"
    config.gem "fastercsv" #, :version => "1.2.0"
    config.gem "mailfactory" #, :version => "1.2.3"
    config.gem "will_paginate" #,:version => "2.1.0"

    # csspool for awesome mailer (next version 2.0.0 does not work)
    # failing with error 
    # Failed to load library '/usr/lib/libcroco-0.6.so': Could not open library '/usr/lib/libcroco-0.6.so': /usr/lib/libcroco-0.6.so: cannot open shared object file: No such file or director
    config.gem "csspool", :version => "0.2.6"
    config.gem "inline_attachment" #:version => "0.3.0"
    config.gem "rubyforge" # :version => "0.4.4",
  
    # for pdf writing
    config.gem "pdf-writer", :lib => false  # => "1.1.3",
    config.gem "color-tools", :lib => false #=> "1.3.0"
    config.gem "transaction-simple", :lib => false # => "1.4.0",

    # this is only needed for produciton use, probalby
    # a debian package dependence is enough
    ## config.gem "passenger", :lib => false
    ## config.gem "fastthread", :lib => false
  end

  # this is done in makefile because compile native extension does not work.	"hpricot" => "0.6.0", # for awesome mailer

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  config.i18n.default_locale = :en
end
