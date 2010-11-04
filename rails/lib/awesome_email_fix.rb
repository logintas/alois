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

# with this the css files can be found in the public/stylesheet director
# multiple css can be defined with "css ['sheet1','sheet2']"
module ActionMailer
  module InlineStyles
    module InstanceMethods
      def parse_css_doc(file_name)
        sac = CSS::SAC::Parser.new
	@css = [@css] if !@css.is_a?(Array)
	sac.parse(@css.map {|css|
		    css = "#{css}.css" unless css =~ /\.css^/
		    file = File.join(RAILS_ROOT, 'public', 'stylesheets', css)	  
		    File.read(file)
		  }.join("\n"))
	
      end
    end
    
    def self.included(receiver)
      receiver.send :include, InstanceMethods
    end
  end
end
      
