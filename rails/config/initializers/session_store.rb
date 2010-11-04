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

# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_alois_session',
  :secret      => 'ef3f8da74daf392d4893dc6783ec350094fd0bf550162d802e837ba845fe60f13456e05ce0a3a05f18d0fd5835f0748856489f1a254f64c495684a8dca758348'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store

#ActionController::Base.cache_store = :memory_store
#ActionController::Base.cache_store = :file_store, "/path/to/cache/directory"
#ActionController::Base.cache_store = :drb_store, "druby://localhost:9192"
#ActionController::Base.cache_store = :mem_cache_store, "localhost"
