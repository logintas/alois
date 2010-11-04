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

class ChartTest < ActiveSupport::TestCase
  fixtures :charts, :views
    
  def test_yaml_hash
    c = Chart.find(:first)
    c.datasource = ApplicationLog
    
    assert_equal ApplicationLog, c.datasource
    

    assert_equal_yaml "--- !ruby/object:Chart \nattributes: \n  column3: \n  time_range: \"2008-04-09\"\n",
                      "--- !ruby/object:Chart \nattributes: \n  time_range: \"2008-04-09\"\n  column3: \n"

    assert_equal_yaml CHART_YAML,c.to_yaml    
    assert_equal Object.yaml_hash(CHART_YAML),Object.yaml_hash(c.to_yaml)
    assert_equal Object.yaml_hash(CHART_YAML),c.yaml_hash

    assert_equal ApplicationLog, c.datasource

    c.render(CHART_RENDER_OPTIONS)

    assert_equal_yaml CHART_AFTER_RENDER_YAML,c.to_yaml
    assert_equal Object.yaml_hash(CHART_AFTER_RENDER_YAML),Object.yaml_hash(c.to_yaml)
    assert_equal Object.yaml_hash(CHART_AFTER_RENDER_YAML),c.yaml_hash
  end

  def test_create_png    
    file_rel = "charts/#{CHART_QUERY.hash}/chart_bar_300x300_#{Object.yaml_hash(CHART_AFTER_RENDER_YAML)}.png"
    file = "#{RAILS_ROOT}/tmp/#{file_rel}"
    link = "<IMG SRC=\"%s\" WIDTH=\"300\" HEIGHT=\"300\" BORDER=\"0\" USEMAP=\"#chart\">"

    c = self.class.test_chart
    assert_equal CHART_QUERY, c.query    
    c.render(CHART_RENDER_OPTIONS)
    assert_equal_yaml CHART_AFTER_RENDER_YAML, c.to_yaml

    assert File.exist?(file), "File '#{file}' does not exist."
    
    assert_equal link % "XXX?a=b&action=chart_image&chart_tmpdir_hash=#{CHART_QUERY.hash}&chart_yaml_hash=#{Object.yaml_hash(CHART_AFTER_RENDER_YAML)}", c.image_tag(:url => "XXX?a=b")


    assert_equal link % Pathname.new(file).realpath.to_s,c.image_tag(:absolute_path => true)
   
    assert_equal link % file_rel,c.image_tag(:relative_path => "#{RAILS_ROOT}/tmp/")

  end

  def test_load_yaml
    c = self.class.test_chart
    c.render(CHART_RENDER_OPTIONS)
    
    img_tag = c.image_tag(:relative_path => "#{RAILS_ROOT}/tmp/")

    c2 = Chart.load_yaml(CHART_QUERY.hash.to_s, Object.yaml_hash(CHART_AFTER_RENDER_YAML).to_s)    
    
    assert_equal c, c2
    assert_equal img_tag, c.image_tag(:relative_path => "#{RAILS_ROOT}/tmp/")

    assert_raise RuntimeError do
      c2.conditions = "(1=1)"
    end
    assert_raise RuntimeError do
      c2.datasource = nil
    end
    assert_equal img_tag, c.image_tag(:relative_path => "#{RAILS_ROOT}/tmp/")
    
  end

  def test_mapping
    ["2008-01-01","2008-01-31","2008-12-01","2008-12-31"].each {|v|
      assert_equal v, Chart.map_to_date(Chart.map_to_number(v))
    }	

    ["00:00:00","23:59:59","00:30:01","12:12:30"].each {|v|
      assert_equal v, Chart.map_to_time(Chart.map_to_number(v))
    }	
  end
  
end
