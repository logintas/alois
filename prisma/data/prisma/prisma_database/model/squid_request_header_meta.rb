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

class SquidRequestHeaderMeta < ActiveRecord::Base
  description "Extended request header of squid messages"
  sources ["SquidMeta"]
  def self.may_have_messages?; false; end
  
  def self.expressions
    ret = []

    # tear out request part of
    # request-header: %>A "%{Authorization}>h" "%{Cache-Control}>h" "%{From}>h" "%{Host}>h" "%{If-Modified-Since}>h" "%{If-Unmodified-Since}>h" "%{Pragma}>h" "%{Proxy-Authorization}>h" response-header: %<A %tr %mt "%{Server}<h" "%{Content-MD5}<h" "%{Age}<h" "%{Cache-Control}<h" "%{Content-Encoding}<h" "%{Content-Language}<h" "%{Date}<h" "%{Last-Modified}>h" "%{Location}>h" "%{Pragma}<h" "%{Proxy-Authenticate}<h" "%{Via}<h" "%{WWW-Authenticate}<h"
    
    #--request-header
    # (client_fqdn:           %>A) already in squid meta
    # authorization:       %{Authorization}>h
    # cache_control:       %{Cache-Control}>h
    # from:                %{From}>h
    # host                 %{Host}>h
    # if_modified_since:   %{If-Modified-Since}>h
    # if_unmodified_since: %{If-Unmodified-Since}>h
    # pragma:              %{Pragma}>h
    # proxy_authorization: %{Proxy-Authorization}>h

    ret.push({ :regex => /request-header: [^ ]+ \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" response-header:/,
	       :fields => [:authorization, :cache_control, :from, :host, 
		 :if_modified_since, :if_unmodified_since, :pragma, :proxy_authorization]
	     })
    ret
  end
end
