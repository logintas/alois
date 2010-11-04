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

class SquidResponseHeaderMeta < ActiveRecord::Base
  description "Extended response header of squid messages"
  sources ["SquidMeta"]
  def self.may_have_messages?; false; end
  
  def self.expressions
    ret = []

    # tear out response part of
    # request-header: %>A "%{Authorization}>h" "%{Cache-Control}>h" "%{From}>h" "%{Host}>h" "%{If-Modified-Since}>h" "%{If-Unmodified-Since}>h" "%{Pragma}>h" "%{Proxy-Authorization}>h" response-header: %<A %tr %mt "%{Server}<h" "%{Content-MD5}<h" "%{Age}<h" "%{Cache-Control}<h" "%{Content-Encoding}<h" "%{Content-Language}<h" "%{Date}<h" "%{Last-Modified}>h" "%{Location}>h" "%{Pragma}<h" "%{Proxy-Authenticate}<h" "%{Via}<h" "%{WWW-Authenticate}<h"

    #--response-header
    # (server_ip:           %<A) already in squid meta
    # (response_time:       %tr) already in squid meta
    # (mime_type:           %mt) already in squid meta
    # server:              %{Server}<h
    # content_md5:         %{Content-MD5}<h
    # age:                 %{Age}<h
    # cache_control:       %{Cache-Control}<h
    # content_encoding:    %{Content-Encoding}<h
    # content_language:    %{Content-Language}<h
    # date:                %{Date}<h
    # last_modified:       %{Last-Modified}>h
    # location:            %{Location}>h
    # pragma:              %{Pragma}<h
    # proxy_autheticate    %{Proxy-Authenticate}<h
    # via:                 %{Via}<h
    # www_authenticate:    %{WWW-Authenticate}<h
    
    
    ret.push({ :regex => /response-header: [^ ]+ [^ ]+ [^ ]+ \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\"$/,
	       :fields => [:server, :content_md5, :age, :cache_control, :content_encoding,
		 :content_language, :date, :last_modified, :location, :pragma, :proxy_authenticate, :via,
		 :www_authenticate]
	     })
    ret
  end
end
