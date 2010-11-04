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

class BaseMailer < ActionMailer::Base
  
  # function from old mail class
  def self.expecting_mail(count = 1)
    raise "Not expecing to use this when not in testing mode." unless RAILS_ENV=="test"
    @expected_mail_count ||= 0
    @expected_mail_count += count
  end
  def self.not_delivered_mails_count
    raise "Not expecing to use this when not in testing mode." unless RAILS_ENV=="test"
    @expected_mail_count or 0
  end
  def self.mail_delivered(mail)
    # decrement expected mails
    if RAILS_ENV == "test"
      raise "No email expected.\n #{mail.to_s}" unless not_delivered_mails_count > 0
      @expected_mail_count -= 1  
    end  
  end
  def self.latest_mail
    deliveries[-1]
  end
  def deliver!(mail = @mail)
    r = super
    BaseMailer.mail_delivered(mail)
    r
  end
  def self.mails
    print "DEPRECATED WARNING: use BaseMailer.deliveries instead of mails.\n"
    deliveries
  end
  def self.smtp_server
    $email_smtp_server or "localhost"
  end
  def self.sender
    $email_sender_address or "alois@logintas.com"
  end
  
  # exception delivering
  def self.send_exception(exceptions)
    exceptions = [exceptions] unless exceptions.class == Array

    ret = "#{exceptions.length} exception ocurred:\n\n\n"

    if $log
      $log.error("Sending #{exceptions.length} execptions to '#{$developper_email}'.")
    end

    exceptions.each {|ex|
      ret += "Message:\n#{ex.to_s}\n\nBacktrace:\n" +
	ex.backtrace.join("\n")

      if $log
	$log.error(ex.to_s)
	ex.backtrace.each {|m| $log.error(m)}
      end

    }

    
    BaseMailer.send_email(:text, $developper_email, "Exception Alert", ret)
  end
  
  # simple send function
  def BaseMailer.send_email(type, addresses, title, content, attachments = [])
    BaseMailer.deliver_oldfashioned(type,addresses,title,content,attachments)
  end

  def oldfashioned(type, addresses, title, content, attachments = [])
    opt = {:title => title, :body => content, :attachments => attachments, :without_object => true }
    case type
    when :html
      html(addresses, nil, opt)
    when :text
      text(addresses, nil, opt)
    else
      raise "Unknown type #{type}"
    end
  end

  # base mailer functions

  def object_name
    if mailer_name =~ /^(.*)\_mailer$/
      return $1
    else
      raise "Cannot compute object name of mailer '#{mailer_name}'."
    end
  end

  def text(recipients, obj, options = {})
    if options[:without_object]
      title = (options[:title] or "Message")
    else
      raise "No #{object_name} given." unless obj
      
      title = nil
      unless title = options[:title]
	if obj.respond_to?(:name)
	  title = "#{object_name.camelize} #{obj.name}"
	else
	  title = "#{object_name.camlize} #{obj.id}"
	end
      end
    end

    # Always prepend installation name
    prefix = ($installation_name or "Alois")
    title = "#{prefix} - #{title}"
    
    recipients recipients
    from       BaseMailer.sender
    subject    title   
    content_type "multipart/alternative"

    layout get_layout("plain")

    part "text/plain" do |p|
      p.charset = "utf-8"
      p.body = (options[:body] or render_message("#{template}.plain.erb", {object_name.to_sym => obj}))
      p.content_disposition = ""
    end

    css get_css
    layout get_layout("html")
  end

  def html(recipients, obj, options = {})   
    p = nil
    if !options[:without_images]
      part "multipart/related" do |p|	
	# not necessary but otherwice a exception is thrown
	p.charset = "uft-8"

	new_part = ActionMailer::Part.new(
					  :content_type => "text/html",
					  :body => (options[:body] or render_message("#{template}.html.erb", 
										     :part_container => p, 
										     object_name => obj)),
					  :disposition => ""
					  )
	# correct buggy implementation. but now you only can use png images.
	# currently the image type is 'image/FILENAME'
	p.parts.each {|mp|
	  mp.content_type = "image/png" if mp.content_type =~ /image/
	}
	
	# The message must be first for thunderbird.
	# Image tag inserts image tags to the beginning of the parts.
	p.parts.insert(0,new_part)
	
	# attach files    
	(options[:attachments] or []).each {|f|
	  attach_file(p,f)
	}
      end      
    else
      part "text/html" do |p|
	p.body = render_message("#{template}.html.erb", {object_name.to_sym => obj})
	p.charset = "utf-8"
	p.content_disposition = ""
      end
    end
    p
  end

  def self.compute_cid(filename)
    filename = Pathname.new(filename).realpath.to_s
    if BaseMailer.sender =~ /\@([\w\d\.]*)/
      domain = $1
    else
      domain = BaseMailer.sender
    end
    
    res = ERB::Util.url_encode(Pathname.new(filename).to_s).hash.abs.to_s + "@" + domain 
    $debug ||= []
    $debug.push([filename,res])
    res
  end

  def self.translate_image_links(text)
    text.gsub(/(src|SRC)=\"([^\"]*)\"/) {|match|
      "#{$1}=\"cid:#{compute_cid($2)}\""
    }
  end

  def layout_name
    ($selected_theme and $selected_theme.layout) or "alois"
  end
  
  def get_layout(type)
    return "#{layout_name}.#{type}" if File.exist?("#{RAILS_ROOT}/app/views/layouts/mailers/#{layout_name}.#{type}.erb")
    return "alois.#{type}" if File.exist?("#{RAILS_ROOT}/app/views/layout/mailers/alois.#{type}.erb")
    return nil
  end

  def get_css    
    ret = ["common","alois-common","alois","alois-screen", layout_name, "#{layout_name}-common","#{layout_name}-screen"]
    ret = ret.select {|f|
      File.exist?("#{RAILS_ROOT}/public/stylesheets/#{f}.css")
    }
    return [] if ret.length == 0
    ret
  end

  def initialize(method_name=nil, *parameters)
    ActionMailer::Base.smtp_settings[:address] = BaseMailer.smtp_server

    if $root_url =~ /^(.*):\/\/(.*[^\/])\/?$/
      ActionMailer::Base.default_url_options[:protocol] = $1
      ActionMailer::Base.default_url_options[:host] = $2
    else
      raise "Cannot parse \$root_url '#{$root_url}'. Need something like https://example.com/alois/"
    end
    super
  end

  def attach_file(part, filename)
    cid = BaseMailer.compute_cid(filename)
    raise "Can only attach pngs" unless filename =~ /.png$/
    part.inline_attachment :content_type => "image/png",
      :body => File.read(filename),
      :filename => Pathname.new(filename).split[1].to_s,
      :cid => "<#{cid}>"    
  end


  def self.preview_html(part)
    ret = ""
    part.parts.each {|p|
      case p.content_type
      when "text/html"
	ret += "<hr>#{p.content_type}<br>"
	ret += p.body
      when "text/plain"
	ret += "<hr>#{p.content_type}<br>"
	ret += "<pre>#{p.body}</pre>"
      end
      ret += preview_html(p)
    }
    ret
  end

end
