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

require 'yaml'

if defined?(RAILS_ROOT)
  ALOIS_DEFAULT_CONFIG = "#{RAILS_ROOT}/config/alois.conf" unless defined?(ALOIS_DEFAULT_CONFIG)
else
  ALOIS_DEFAULT_CONFIG = "/etc/alois/alois.conf" unless defined?(ALOIS_DEFAULT_CONFIG)
end

def get_replacements(configfile)
  # prepare regexps
  replacements = {}
  configs = read_config(configfile, false)
  for (configname,config) in configs
    for (valuename,value) in config
      replacements["{{#{configname}.#{valuename}}}"] = value
    end if not config == nil
  end
  return replacements
end

def replace_configurations(replacements, value)
  def str_sub(replacements, value)
    for (reg,val) in replacements
      value = value.gsub(reg.to_s,val.to_s)
    end
    print "WARNING: Not replaced:#{value}" if value =~ /\{\{/ or value =~ /\}\}/
    return value
  end

  case value.class.to_s
  when "String"
    return str_sub(replacements, value)
  when "Array"
    return value.map { |v| replace_configurations(replacements, v)}
  else
    return value
  end
end


def read_config(configfile = nil, with_replace = true)
  configfile = ALOIS_DEFAULT_CONFIG unless configfile
  return $current_config if $current_config_file == configfile and $current_replacement == with_replace

  configfile = ALOIS_DEFAULT_CONFIG unless configfile
  tree = YAML::parse(File.open(configfile))

  configurations = tree["/configs/*"]
  configurations = tree.select("/configs")[0].transform

  for (name, configname) in configurations
    c = tree.select("/#{configname}")[0]
    c = c.transform if not c == nil
    configurations[name] = c
  end

  if with_replace
    replacements = get_replacements(configfile)

    for (service, host) in configurations
      throw "#{host} configuration not found!" unless host
      for (name, value) in host
        host[name] = replace_configurations(replacements, value)
      end
    end
  end

  $current_config_file = configfile
  $current_config = configurations
  $current_replacement = with_replace
  throw "Configuration could not be loaded." unless configurations
  return configurations
end

def get_config(name, property, default_value = nil)
  v = read_config
  return default_value unless v
  v = v[name]
  return default_value unless v
  v = v[property]
  return default_value unless v
  return v
end
