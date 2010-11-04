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

class SquidMeta < ActiveRecord::Base
  description "Parsed squid messages"
  sources ["PureMeta", "LogMeta"]
  def self.may_have_messages?; true; end

# from: http://www.squid-cache.org/Versions/v2/2.6/cfgman/logformat.html
#     Usage:
#
#        logformat <name> <format specification>
#
#        Defines an access log format.
#
#        The <format specification> is a string with embedded % format codes
#
#        % format codes all follow the same basic structure where all but
#        the formatcode is optional. Output strings are automatically escaped
#        as required according to their context and the output format
#        modifiers are usually not needed, but can be specified if an explicit
#        output format is desired.
#
#                % ["|[|'|#] [-] [[0]width] [{argument}] formatcode
#
#                "       output in quoted string format
#                [       output in squid text log format as used by log_mime_hdrs
#                #       output in URL quoted format
#                '       output as-is
#
#                -       left aligned
#                width   field width. If starting with 0 the
#                        output is zero padded
#                {arg}   argument such as header name etc
#
#        Format codes:
#
#                >a      Client source IP address
#                >A      Client FQDN
#                >p      Client source port
#                <A      Server IP address or peer name
#                la      Local IP address (http_port)
#                lp      Local port number (http_port)
#                ts      Seconds since epoch
#                tu      subsecond time (milliseconds)
#                tl      Local time. Optional strftime format argument
#                        default %d/%b/%Y:%H:%M:%S %z
#                tg      GMT time. Optional strftime format argument
#                        default %d/%b/%Y:%H:%M:%S %z
#                tr      Response time (milliseconds)
#                >h      Request header. Optional header name argument
#                        on the format header[:[separator]element]
#                <h      Reply header. Optional header name argument
#                        as for >h
#                un      User name
#                ul      User name from authentication
#                ui      User name from ident
#                us      User name from SSL
#                ue      User name from external acl helper
#                Hs      HTTP status code
#                Ss      Squid request status (TCP_MISS etc)
#                Sh      Squid hierarchy status (DEFAULT_PARENT etc)
#                mt      MIME content type
#                rm      Request method (GET/POST etc)
#                ru      Request URL
#                rv      Request protocol version
#                ea      Log string returned by external acl
#                <st     Reply size including HTTP headers
#                >st     Request size including HTTP headers
#                st      Request+Reply size including HTTP headers
#                %       a literal % character
#
#  logformat squid      %ts.%03tu %6tr %>a %Ss/%03Hs %<st %rm %ru %un %Sh/%<A %mt
#  logformat squidmime  %ts.%03tu %6tr %>a %Ss/%03Hs %<st %rm %ru %un %Sh/%<A %mt [%>h] [%<h]
#  logformat common     %>a %ui %un [%tl] "%rm %ru HTTP/%rv" %Hs %<st %Ss:%Sh
#  logformat combined   %>a %ui %un [%tl] "%rm %ru HTTP/%rv" %Hs %<st "%{Referer}>h" "%{User-Agent}>h" %Ss:%Sh
  
  def self.expressions
    ret = []
   
    # Jun 10 06:38:19 hill squid[2573]: 1213072699.830      0 192.168.61.210 TCP_NEGATIVE_HIT/404 628 GET http://www.ossim.net/download/debian/Release.gpg - NONE/- text/html

    #                                        squid combined     combined_logintas
    # seconds_since_epoch: %ts                 *   (local_time)
    # subsecond_time:      %03tu               *      
    # response_time_milliseconds: %6tr         *                    *
    # client_source_ip:    %>a                 *      *
    # request_status:      %Ss                 *      *
    # http_status_code:    %03Hs               *      *
    # reply_size:          %<st                *      *
    # request_method:      %rm                 *      *
    # request_url:         %ru                 *      *
    # user_name            %un                 *      *
    # hierarchy_status:    %Sh                 *      *
    # server_ip:           %<A                 *                    *
    # mime_type:           %mt                 *                    *
    #COMBINED NEW:
    # user_indent:         %ui                        *
    # protocol_version:    %rv                        *
    # referer:             %{Referer}>h               *
    # user_agent:          %{User-Agent}>h            *
    #LOGINTAS COMBINED NEW:
    # user_auth:           %ul
    # user_acl:            %ue
    # acl_log:             %ea
    # client_fqdn:         %>A

    

    #  logformat squid      %ts.%03tu %6tr %>a %Ss/%03Hs %<st %rm %ru %un %Sh/%<A %mt
    ret.push({ :regex => /^(squid\[([^\]]+)\]:\s+)?(\d+)\.(\d\d\d)\s+(\d+) ([^ ]+) ([^\/]+)\/(\d+) (\d+) ([^ ]+) ([^ ]+) ([^ ]+) ([^\/]+)\/([^ ]+) (.+)\s*$/,
	       :fields => [nil,:process_id,:seconds_since_epoch, :subsecond_time, :response_time_milliseconds, 
		 :client_source_ip, :request_status, :http_status_code, :reply_size, 
		 :request_method, :request_url, :user_name, :hierarchy_status, :client_fqdn, :mime_type]
	     })

    # one of syslogs default format
    # squid combined format:
    # logformat combined %>a %ui %un [%tl] "%rm %ru HTTP/%rv" %Hs %<st "%{Referer}>h" "%{User-Agent}>h" %Ss:%Sh
    # 192.168.61.77 - - [29/Sep/2009:06:34:35 +0200] "GET http://debian.setup.in.here/mgmt-sarge/Release.gpg HTTP/1.0" 304 271 "-" "Debian APT-HTTP/1.3" TCP_REFRESH_HIT:DIRECT
    ret.push({ :regex => /^(\d+\.\d+\.\d+\.\d+) ([^ ]+) ([^ ]+) \[([^\]]*)\] \"([^ ]+) ([^ ]+) HTTP\/([^\"]+)\" (\d+) (\d+) \"([^\"]*)\" \"([^\"]*)\" ([^:]+):([^ ]+) ?(.*)\n?$/,
	       :fields => [:client_source_ip, :user_indent, :user_name, :seconds_since_epoch, 
		 :request_method, :request_url, :protocol_version, :http_status_code, :reply_size, :referer, :user_agent,
		 :request_status, :hierarchy_status, :message],
	       :result_filter => lambda {|results, meta_instance|
		 results[3] = Time.parse(DateTime.strptime(results[3],"%d/%b/%Y:%H:%M:%S %Z").to_s).to_i
		 results
	       }

	     })
  end
  
  def after_filling_values(values)
    # get protocol and host from url
    if %r{^(\w+)\://([^/]+)(/.*|$)$} =~ values[:request_url]
      self.request_protocol = $1
      self.request_host = $2
    end

    if self.message
      raise "Get values of extended format"
      # extendes logintas format   
      # logformat logintas_accesslog %>a %ui %un [%tl] "%rm %ru HTTP/%rv" %Hs %<st "%{Referer}>h" "%{User-Agent}>h" %Ss:%Sh [lit:] %ul %ue %ea request-header: %>A "%{Authorization}>h" "%{Cache-Control}>h" "%{From}>h" "%{Host}>h" "%{If-Modified-Since}>h" "%{If-Unmodified-Since}>h" "%{Pragma}>h" "%{Proxy-Authorization}>h" response-header: %<A %tr %mt "%{Server}<h" "%{Content-MD5}<h" "%{Age}<h" "%{Cache-Control}<h" "%{Content-Encoding}<h" "%{Content-Language}<h" "%{Date}<h" "%{Last-Modified}>h" "%{Location}>h" "%{Pragma}<h" "%{Proxy-Authenticate}<h" "%{Via}<h" "%{WWW-Authenticate}<h"
      #
      # extends the combined format with 
      #    [lit:] %ul %ue %ea request-header: %>A "%{Authorization}>h" "%{Cache-Control}>h" "%{From}>h" "%{Host}>h" "%{If-Modified-Since}>h" "%{If-Unmodified-Since}>h" "%{Pragma}>h" "%{Proxy-Authorization}>h" response-header: %<A %tr %mt "%{Server}<h" "%{Content-MD5}<h" "%{Age}<h" "%{Cache-Control}<h" "%{Content-Encoding}<h" "%{Content-Language}<h" "%{Date}<h" "%{Last-Modified}>h" "%{Location}>h" "%{Pragma}<h" "%{Proxy-Authenticate}<h" "%{Via}<h" "%{WWW-Authenticate}<h"
      # 
      
    end

  end
  
end
	       
