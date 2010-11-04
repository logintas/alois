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

# otherwise an exception occurs here
# when building mails in console
# /var/local/share/home/fpellanda/logintas/alois/alois-1.0/rails/vendor/rails/actionpack/lib/action_view/base.rb:419:in `template_format'
class DummyClass
  def parameters
    {}
  end
  def protocol
    "dummyprotocol"
  end
end
