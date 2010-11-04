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
require 'tablelist_controller'

# Re-raise errors caught by the controller.
class TablelistController; def rescue_action(e) raise e end; end

class TablelistControllerTest < ActionController::TestCase
  def setup
    @controller = TablelistController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
  end

  def test_count
    for klass in Prisma::Database.get_classes
      get :count, :table_name => klass.table_name

      assert_response :success
      assert_template 'count'
    end
  end

end
