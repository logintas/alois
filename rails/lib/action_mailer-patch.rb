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

module ActionMailer
  # Represents a subpart of an email message. It shares many similar
  # attributes of ActionMailer::Base.  Although you can create parts manually
  # and add them to the +parts+ list of the mailer, it is easier
  # to use the helper methods in ActionMailer::PartContainer.
  class Part
    # Convert the part to a mail object which can be included in the parts
    # list of another mail object.
    def to_mail(defaults)
      part = TMail::Mail.new

      real_content_type, ctype_attrs = parse_content_type(defaults)

      if @parts.empty?
        part.content_transfer_encoding = transfer_encoding || "quoted-printable"
        case (transfer_encoding || "").downcase
          when "base64" then
            part.body = TMail::Base64.folding_encode(body)
          when "quoted-printable"
            part.body = [normalize_new_lines(body)].pack("M*")
          else
            part.body = body
        end

        # Always set the content_type after setting the body and or parts!
        if content_disposition == "attachment"
          ctype_attrs.delete "charset"
	end

        # Also don't set filename and name when there is none (like in
        # non-attachment parts)
	if filename
          ctype_attrs.delete "charset"
          part.set_content_type(real_content_type, nil,
            squish("name" => filename).merge(ctype_attrs))
          part.set_content_disposition(content_disposition,
            squish("filename" => filename).merge(ctype_attrs))
        else
          part.set_content_type(real_content_type, nil, ctype_attrs)
          part.set_content_disposition(content_disposition)
        end
      else
        if String === body
          @parts.unshift Part.new(:charset => charset, :body => @body, :content_type => 'text/plain')
          @body = nil
        end
          
        @parts.each do |p|
          prt = (TMail::Mail === p ? p : p.to_mail(defaults))
          part.parts << prt
        end
        
        if real_content_type =~ /multipart/
          ctype_attrs.delete 'charset'
          part.set_content_type(real_content_type, nil, ctype_attrs)
        end
      end

      headers.each { |k,v| part[k] = v }

      part
    end
  end
end
