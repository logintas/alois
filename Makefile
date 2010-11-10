VERBOSE=0

srcdir = $(shell pwd)
INSTALL = /usr/bin/install
LN = /bin/ln -sf

DESTDIR = /tmp/alois-install
PREFIX = /usr/local

APP_NAME=alois
VERSION=1.0
#CONFIG_TYPE="testing"
CONFIG_TYPE=""

# sources
SOURCE_ETC=$(srcdir)/etc
SOURCE_CONFIG_DIR=$(SOURCE_ETC)/$(APP_NAME)
SOURCE_ENV_DIR=$(SOURCE_CONFIG_DIR)/environments
SOURCE_DEFAULTCONFIG_DIR=$(srcdir)/etc/default

SOURCE_RAILS=$(srcdir)/rails
RAILS_CONFIG_FILES=$(APP_NAME).conf boot.rb environment.rb database.yml routes.rb munin-sink.conf munin.conf
RAILS_ENV_FILES=development.rb production.rb test.rb

TARGET_MAIN=$(DESTDIR)$(PREFIX)/share/$(APP_NAME)
TARGET_RUBYLIB=$(DESTDIR)$(PREFIX)/lib/ruby/1.8
TARGET_LIB=$(DESTDIR)/var/lib
TARGET_ETC = $(DESTDIR)$(PREFIX)/etc
TARGET_BIN=$(DESTDIR)$(PREFIX)/bin
TARGET_SBIN=$(DESTDIR)$(PREFIX)/sbin
TARGET_DOC=$(DESTDIR)$(PREFIX)/share/doc/$(APP_NAME)
TARGET_CONFIG_DIR=$(TARGET_ETC)/$(APP_NAME)
TARGET_DEFAULTCONFIG_DIR=$(TARGET_ETC)/default
TARGET_ENV_DIR=$(TARGET_CONFIG_DIR)/environments
TARGET_RAILS=$(TARGET_MAIN)/www
TARGET_RAILS_CONFIG=$(TARGET_RAILS)/config
TARGET_RAILS_ENV=$(TARGET_RAILS_CONFIG)/environments

WORKING_CONFIG=$(srcdir)/development_configs
RAKE_COMMAND=cd $(SOURCE_RAILS); rake 

all: build

# build target and freeze gems
rails/java/CreateChart.class: rails/java/CreateChart.java
	cd $(SOURCE_RAILS); ./script/compile_java

init-dirs:
	@echo "Building $(SOURCE_RAILS)"
	$(MAKE) installconfig DESTDIR=$(WORKING_CONFIG) CONFIG_TYPE=local INSTALL="ln -fs"
	$(MAKE) installlinks DESTDIR=$(WORKING_CONFIG) TARGET_RAILS=$(SOURCE_RAILS) CONFIG_TYPE=_local
	chmod 755 $(SOURCE_RAILS)/script/* $(SOURCE_RAILS)/public/dispatch.*

init-plugins:
# git://github.com/imedo/awesome_email.git
	mkdir -p $(SOURCE_RAILS)/vendor/plugins
	rsync --exclude .svn -rv rails_plugins/awesome_email $(SOURCE_RAILS)/vendor/plugins/
	rsync --exclude .svn -rv rails_plugins/auto_complete $(SOURCE_RAILS)/vendor/plugins/

init: init-dirs init-plugins rails/java/CreateChart.class


export GEM_HOME := $(srcdir)/gems
export GEM_PATH := $(srcdir)/gems
freeze-gems: init-dirs
	@echo "Gem home: ${GEM_HOME} Gem path: ${GEM_PATH}"
	@echo "Downloading rails"
	gem install -V -v=2.3.2 rails
	gem install libisi
	@echo "Installing required gems"
	$(RAKE_COMMAND) --trace "gems:install"
	@echo "Freezing gems"
	$(RAKE_COMMAND) "rails:freeze:gems"
	@echo "Build required gems"
	$(RAKE_COMMAND) "gems:build"

init-db:
	cd prisma/ ; ruby bin/prisma load prisma
	cd prisma/ ; ruby bin/prisma load pumpy
	$(RAKE_COMMAND) "db:schema:load"

build: init-dirs rails/java/CreateChart.class init-plugins
	touch alois-build

installlinks:
	@echo "Creating links in $(TARGET_RAILS_ENV)"
	$(foreach file, $(RAILS_ENV_FILES),  $(LN) $(TARGET_ENV_DIR)/$(file) $(TARGET_RAILS_ENV)/$(file) ;) 	
	@echo "Creating links in $(TARGET_RAILS_CONFIG)"
	$(foreach file, $(RAILS_CONFIG_FILES), $(LN) $(TARGET_CONFIG_DIR)/$(file) $(TARGET_RAILS_CONFIG)/$(file) ;) 
	$(LN) $(TARGET_DEFAULTCONFIG_DIR)/alois-environment.rb $(TARGET_RAILS_CONFIG)/default_environment.rb
	$(LN) $(TARGET_DEFAULTCONFIG_DIR)/alois-environment-config.rb $(TARGET_RAILS_CONFIG)/default_config.rb

uninstalllinks:
	-$(foreach file, $(RAILS_ENV_FILES),  rm -f $(TARGET_RAILS_ENV)/$(file) ;) 	
	-$(foreach file, $(RAILS_CONFIG_FILES), rm -f $(TARGET_RAILS_CONFIG)/$(file) ;) 
	-rm -f $(TARGET_RAILS_CONFIG)/default_environment.rb
	-rm -f $(TARGET_RAILS_CONFIG)/default_config.rb

uninstallconfig:
	@echo "Uninstalling config files from $(TARGET_CONFIG_DIR)"
#	rm -f $(TARGET_LIB)/prisma/archive/README
	-rmdir  $(TARGET_LIB)/prisma/archive
	-rmdir  $(TARGET_LIB)/alois/archive
	rm -f $(TARGET_CONFIG_DIR)/apache2/apache.conf
	rm -f $(TARGET_CONFIG_DIR)/apache2/alois.passwd
	rmdir $(TARGET_CONFIG_DIR)/apache2
#	rm -f $(TARGET_DOC)/syslog-ng.conf.example
	- rmdir $(TARGET_DOC)

#	rm -f $(TARGET_SBIN)/alois-cleanup-raws
#	rm -f $(TARGET_SBIN)/alois-mysqlpipe
#	rm -f $(TARGET_SBIN)/alois-updatepasswords
#	rm -f $(TARGET_BIN)/alois-sendlog
#	-rmdir $(TARGET_SBIN)
	-rmdir $(TARGET_BIN)

#	rm -f $(TARGET_RAILS)/app/models/packaged_for_alois_schema_version
#	rm -f $(TARGET_RAILS)/app/models/packaged_for_pumpy_schema_version

	rm -f $(TARGET_ETC)/cron.d/alois-prisma
	rm -f $(TARGET_ETC)/cron.d/alois-sink
	-rmdir $(TARGET_ETC)/cron.d
	rm -f $(TARGET_ETC)/logrotate.d/alois-prisma
	rm -f $(TARGET_ETC)/logrotate.d/alois-sink
	-rmdir $(TARGET_ETC)/logrotate.d
	rm -f $(TARGET_DEFAULTCONFIG_DIR)/alois-environment.rb
	rm -f $(TARGET_DEFAULTCONFIG_DIR)/alois-environment-config.rb
	-rmdir $(TARGET_DEFAULTCONFIG_DIR)
	$(foreach file, $(RAILS_ENV_FILES),  rm -f $(TARGET_ENV_DIR)/$(file);) 
	-rmdir $(TARGET_ENV_DIR)
	$(foreach file, $(RAILS_CONFIG_FILES), rm -f $(TARGET_CONFIG_DIR)/$(file);) 
	-rmdir $(TARGET_CONFIG_DIR)

# ensure that the INSTALL here may also be "ln -s"
installconfig:
	@echo "Installing config files to $(TARGET_CONFIG_DIR)"
	mkdir -p $(TARGET_CONFIG_DIR)
	$(foreach file, $(RAILS_CONFIG_FILES),  $(INSTALL) $(SOURCE_CONFIG_DIR)/$(file) $(TARGET_CONFIG_DIR)/$(file);) 
	if test -f $(SOURCE_CONFIG_DIR)/environment_$(CONFIG_TYPE).rb ; then $(INSTALL) $(SOURCE_CONFIG_DIR)/environment_$(CONFIG_TYPE).rb $(TARGET_CONFIG_DIR)/environment.rb ; fi
	mkdir -p $(TARGET_ENV_DIR)
	$(foreach file, $(RAILS_ENV_FILES),  $(INSTALL) $(SOURCE_ENV_DIR)/$(file) $(TARGET_ENV_DIR)/$(file);) 
	mkdir -p $(TARGET_DEFAULTCONFIG_DIR)
	$(INSTALL) $(SOURCE_DEFAULTCONFIG_DIR)/alois-environment.rb $(TARGET_DEFAULTCONFIG_DIR)/alois-environment.rb
	$(INSTALL) $(SOURCE_DEFAULTCONFIG_DIR)/alois-environment-config.rb $(TARGET_DEFAULTCONFIG_DIR)/alois-environment-config.rb
	mkdir -p $(TARGET_ETC)/cron.d
	$(INSTALL) $(SOURCE_ETC)/cron.d/alois-prisma $(TARGET_ETC)/cron.d/alois-prisma
	$(INSTALL) $(SOURCE_ETC)/cron.d/alois-sink $(TARGET_ETC)/cron.d/alois-sink
	mkdir -p $(TARGET_ETC)/logrotate.d
	$(INSTALL) $(SOURCE_ETC)/logrotate.d/alois-prisma $(TARGET_ETC)/logrotate.d/alois-prisma
	$(INSTALL) $(SOURCE_ETC)/logrotate.d/alois-sink $(TARGET_ETC)/logrotate.d/alois-sink
	mkdir -p $(TARGET_CONFIG_DIR)/apache2
	$(INSTALL) $(SOURCE_CONFIG_DIR)/apache2/apache.conf $(TARGET_CONFIG_DIR)/apache2/apache.conf
	$(INSTALL) $(SOURCE_CONFIG_DIR)/apache2/alois.passwd $(TARGET_CONFIG_DIR)/apache2/alois.passwd

install: installconfig
	@echo $(TARGET_MAIN)
	@echo "Installing app to $(TARGET_MAIN)"
# copy whole rails folder to main path
	mkdir -p $(TARGET_RAILS)
	cp -rT $(SOURCE_RAILS) $(TARGET_RAILS)
	$(INSTALL) -m 775 -d $(TARGET_RAILS)/log
	$(INSTALL) -m 775 -d $(TARGET_RAILS)/tmp
#	mkdir -p $(TARGET_SBIN)
	mkdir -p $(TARGET_BIN)
#	$(INSTALL) -m 755 bin/alois-cleanup-raws $(TARGET_SBIN)/alois-cleanup-raws
#	$(INSTALL) -m 755 bin/alois-mysqlpipe $(TARGET_SBIN)/alois-mysqlpipe
#	$(INSTALL) -m 755 bin/alois-updatepasswords $(TARGET_SBIN)/alois-updatepasswords
#	$(INSTALL) -m 755 bin/alois-sendlog $(TARGET_BIN)/alois-sendlog
	mkdir -p $(TARGET_DOC)
	$(INSTALL) -m 664 prisma/doc/syslog-ng.conf.example $(TARGET_DOC)/syslog-ng.conf.example
	mkdir -p $(TARGET_LIB)/prisma/archive
	mkdir -p $(TARGET_LIB)/alois/archive
#	$(INSTALL) -m 644 doc/README-prisma-archive $(TARGET_LIB)/prisma/archive/README
	mkdir -p $(TARGET_RUBYLIB)
	cp -rT $(SOURCE_RAILS)/lib/alois $(TARGET_RUBYLIB)/alois
	echo $(TARGET_RUBYLIB)

clean:
	rm -rf $(SOURCE_RAILS)/vendor
	rm -rf $(SOURCE_RAILS)/log
	rm -rf $(SOURCE_RAILS)/tmp
	-$(MAKE) uninstallconfig DESTDIR=$(WORKING_CONFIG)
	-$(MAKE) uninstalllinks DESTDIR=$(WORKING_CONFIG) TARGET_RAILS=$(SOURCE_RAILS)
# do not remove class files, they cannot be compiled in etch anymore so keep them
# they are anyway architecture independent
#	rm $(SOURCE_RAILS)/java/*.class
	rm -rf $(WORKING_CONFIG)

mrproper: clean
	rm -rf gems
