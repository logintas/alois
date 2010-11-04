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

require File.dirname(__FILE__) + '/../test_helper'
require 'prisma_controller'

# Re-raise errors caught by the controller.
class PrismaController; def rescue_action(e) raise e end; end

class PrismaControllerTest < ActionController::TestCase
  
  def setup
    @controller = PrismaController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = Alarm.find(:first).id
  end

  def test_overview
    get :overview
    assert_response :success
    assert_tidy_html
  end

  def test_overview_1tier
    get :overview, :installation_schema => "1tier"
    assert_response :success
    assert_tidy_html
  end
  def test_overview_3tier
    get :overview, :installation_schema => "3tier"
    assert_response :success
    assert_tidy_html
  end

  def test_measure_inline   
    for stat in PrismaController::STAT_NAMES
      get :measure_inline, :type => stat
    end    
  end
  
end
