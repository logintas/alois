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

# This class contains basic, static functionalities that
# can be run from other places in alois or from scripts.
class PrismaOLD
  require 'zlib'

  def Prisma.filter_class
    # workaround for controllers that cannot access
    # class Filter because of the class ActionController::Filters::Filter
    Filter
  end

    
  
  # Return all alois base classes. Raw/Meta/Message and Alois Models
  def Prisma.get_classes(type = :all)
    unless $all_classes_loaded
      Dir.glob(RAILS_ROOT + "/app/models/*.rb").map {|c|
	require c
      }
      $all_classes_loaded = true
    end
    @klasses = subclasses_of(ActiveRecord::Base).select {|klass| klass.table_exists? } unless @klasses

    ret = @klasses.reject { |klass|
      !((klass.name =~ /(.*)Raw$/ and type == :raw) or
        (klass.name =~ /(.*)Meta$/ and type == :meta) or
        (klass.name =~ /(.*)Message$/ and type == :message) or
         type == :all) or
        klass.name =~/GenericRecord/ or
        klass.name =~/BaseSource/ or
	!klass.respond_to?(:table)
    }
    return ret
  end

  # Common function to check if instance is productive
  def Prisma.is_productive?
    RAILS_ENV=="production"
  end



  # Return all configured connections.
  def Prisma.connections
    Prisma.get_classes(:all).map{ |klass| klass.connection }.uniq
  end
  # Reconnect all connetions, use this if you for or daemonize
  # processes.
  def Prisma.reconnect
return
    Prisma.connections.each {|c| c.disconnect!}
    Prisma.check_connections
  end
  
  # Check if all classes can be accessed
  def Prisma.check_connections
    # IS THIS NOW OBSOLETE??
    # do only check connection in production
    # mode, eg in testing the transactional
    # fixtures would be messed up
    #    return true unless RAILS_ENV == "production"

    $log.info "Connection check"
    ret = Prisma.get_classes(:all).map{ |klass| 
      begin
	c = klass.connection
	c.verify!
	nil
      rescue ActiveRecord::Transactions::TransactionError
	raise $!
      rescue  
	"  #{$!.message}"
      end
    }.uniq.compact
    if ret.length == 0
      $log.info{"  All connections active."}
      true
    else
      for msg in ret 
	$log.warn(msg)
      end
      false
    end
  end
  
  # Load default views, this can be done after a fresh installation
  def Prisma.load_default_working_items
    iew.load_from_yaml("#{RAILS_ROOT}/config/default_working_items/views.yaml") rescue [$!.to_s]
  end
end
