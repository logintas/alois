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
require 'survey_controller'

# Re-raise errors caught by the controller.
class SurveyController; def rescue_action(e) raise e end; end

class SurveyControllerTest < ActionController::TestCase
  fixtures :views, :application_logs

  def setup
    @controller = SurveyController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    # without any record ruport would fail with: Ruport::FormatterError: Can't output table without data or column names.
    ApplicationLog.create(:date => DateTime.now.strftime("%F"))
  end


  def test_index
    get :index, :table => "application_logs"

    assert_response :redirect
    assert_redirected_to :action => 'list'    
  end

  def test_list_redirect
    get :list, :table => "application_logs"
    
    assert_response :redirect
    assert_redirected_to :action => 'list'    
  end

  def test_list
    get :list, :table => "application_logs", :state_id => "test_state"
    
    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:records)
  end

  def test_show_syslog
    get :show, :id => 1, :table => "application_logs"

    assert_response :success
    assert_template 'show'
  end

  def test_show_message
    get :show, :id => 1, :table => "application_logs"

    assert_response :success
    assert_template 'show'
  end

  def test_new
    assert_raises(ActionController::UnknownAction){
      get :new, :table => "application_logs"
    }
  end

  def test_create
    assert_raises(ActionController::UnknownAction){
      post :create, :table => "application_logs"
    }
  end

  def test_edit
    assert_raises(ActionController::UnknownAction){
      get :edit, :id => 1, :table => "application_logs"
    }
  end

  def test_update
    assert_raises(ActionController::UnknownAction){
      post :update, :id => 1, :table => "application_logs"
    }
  end

  def test_destroy
    assert_raises(ActionController::UnknownAction){
      post :destroy, :id => 1, :table => "application_logs"
    }
  end

  def test_txt
    get :text, :id => 1, :table => "application_logs"
    assert_response :success
  end

  def test_csv
    get :csv, :id => 1, :table => "application_logs"
    assert_response :success
  end

  def test_pdf
    get :pdf, :id => 1, :table => "application_logs"
    assert_response :success
  end

  def test_count
    get :count_text, :table => "view_11"
    assert_response :success
    
    assert @response.body =~ /This can take a very long time./
  end

  def test_count_slow
    get :count_text, :table => "view_11", :slow_count => true, :no_default_filter => true
    assert_response :success
    
    assert @response.body =~ /You have selected 10 records/, "'#{@response.body}'\n does not contain 'You have selected 80 records'. "
  end

  def test_default_condition
    get :list, :table => "application_logs", :default_filter => "1=1"
    assert_response :redirect
    assert_redirected_to(:controller => "survey", :action => "list", :state_id => ApplicationHelper::TEST_STATE_ID)

    assert_equal 2,@response.redirected_to.length
    assert @response.redirected_to[:state_id]
    get :list, @response.redirected_to
    assert_response :success

    assert_not_nil assigns(:records)
    df = assigns(:current_filter)
    assert_not_nil df
    assert 1,df.conditions.length
    cond = df.conditions[0]
    
    assert cond.is_a?(SqlCondition)
    assert_equal "SQL",cond.operator
    assert_equal "1=1",cond.value
    assert_equal "( 1=1 )",cond.sql    
  end


  def test_add_condition
    get :add_condition, :table => "application_logs", :state_id => "test_state",
      :no_default_filter => "true", :column => "id", :operator => "=", :value => "1"

    assert_response :redirect
    assert_equal 1, assigns("current_filter").conditions.length
    assert_equal Condition.new("id","=","1").sql, assigns("current_filter").conditions[0].sql
  end

  def test_add_condition2
    get :add_condition, :table => "application_logs", :state_id => "test_state",
      :no_default_filter => "true",
      :column => "id", :operator => "=", :value => "1",
      :column2 => "id", :operator2 => "LIKE", :value2 => "2"

    assert_response :redirect
    assert_equal 2, assigns("current_filter").conditions.length
    assert_equal Condition.new("id","=","1").sql, assigns("current_filter").conditions[0].sql
    assert_equal Condition.new("id","LIKE","2").sql, assigns("current_filter").conditions[1].sql
  end

  def test_add_conditions
    get :add_condition, :table => "application_logs", :state_id => "test_state",
      :no_default_filter => "true",
      :columns => ["id","date","date"], :operators => ["=","LIKE","DATE"], :values => ["1","2008-01-01","today"]

    assert_response :redirect
    assert_equal 3, assigns("current_filter").conditions.length
    assert_equal Condition.new("id","=","1").sql, assigns("current_filter").conditions[0].sql
    assert_equal Condition.new("date","LIKE","2008-01-01").sql, assigns("current_filter").conditions[1].sql
    assert_equal Condition.new("date","=",DateTime.now.strftime("%F")).sql, assigns("current_filter").conditions[2].sql.strip
  end

  def test_chart_click_compatibility
    ## Leave this tests for backwarts compatibility!
    @stateid = "teststate"    
    get :chart_click,
      :column1 => "request_status", :column2 => "", 
      :series => "Serie 1", :category => "TCP_MISS"

    assert_redirected_to :action => "add_condition", :state_id => assigns("state_id"),
      :columns => ["request_status"],
      :operators => ["="],
      :values => ["TCP_MISS"]
    
    get :chart_click,
      :column1 => "request_status", :column2 => "", 
      :series => "Serie 1", :category => "TCP_REFRESH_HIT"

    assert_redirected_to :action => "add_condition", :state_id => assigns("state_id"),
      :columns => ["request_status"],
      :operators => ["="], 
      :values => ["TCP_REFRESH_HIT"]

    # xy
    get :chart_click,
      :column1 => "request_status", :column2 => "hour",
      :series => "hour=2", :category => "TCP_HIT"

    assert_redirected_to :action => "add_condition", :state_id => assigns("state_id"),
      :columns => ["request_status","hour"],
      :operators => ["=","="], 
      :values => ["TCP_HIT", "2"]
    
    get :chart_click,
      :column1 => "request_status", :column2 => "hour", 
      :series => "hour=6", :category => "TCP_REFRESH_HIT"

    assert_redirected_to :action => "add_condition", :state_id => assigns("state_id"),
      :columns => ["request_status","hour"],
      :operators => ["=","="],
      :values => ["TCP_REFRESH_HIT","6"]

    # xyz
    get :chart_click,
      :category_column => "hour", :serie_column => "level",:range_column => "facility",
      :category => "10", :series => "level=warning", :range => "facility=user"
    
    assert_redirected_to :action => "add_condition", :state_id => assigns("state_id"),
      :columns => ["hour","level","facility"], 
      :operators => ["=","=","="], 
      :values => ["10","warning", "user"]

  end

end
