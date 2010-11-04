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

module SurveyHelper

  def children_table(record, processed = [])
    return "" if record.class.name =~ /.*Raw$/
    return "" if record.class.name =~ /^Message$/   
    while record.is_a?(GenericRecord)
      record = record.parent
    end
    return "" unless record

    ret = ""

    for klass in Prisma::Database.get_classes(:meta)
      for column in klass.columns
	f_column = record.class.foreign_column_name
	if column.name == f_column then
	  # count how many record there are
	  ret += (children_line(klass, f_column, record, processed) or "NO CHILDREN")
	end
      end
    end
    ret += (children_line(Message, nil, record, processed) or "NO CHILDREN")
    for view in View.find(:all,:conditions => ["id_source_table = ?",record.class.table_name])
      ret += children_line(view, "id", record, processed)
    end
    
    return nil if ret == "" 
    return "All children of #{record.class.name}.#{record.id}:<br>#{ret}"
  end

  def children_line(klass, col, parent, processed)
    n = nil
    if klass == Message
      n = klass.count(:conditions => "meta_type_name = 'Prisma::#{parent.class.to_s}' AND meta_id = #{parent.id}")
    else
      if klass.is_a?(View)
	n = nil
      else
	n = klass.table.count(:conditions => "#{col} = #{parent.id}")
      end
    end

    link = nil
    ret = "<ul>"
    case n
    when 0
      ret += "No children in #{klass.name}"
    when 1
      if klass == Message
	child = klass.table.find(:all,:conditions => "meta_type_name = 'Prisma::#{parent.class.to_s}' AND meta_id = #{parent.id}")[0]
      else
	child = klass.table.find(:all,:conditions => "#{col} = #{parent.id}")[0]
      end
      
      link = link_to("#{klass.name}.#{parent.id}",:action =>'show',
		     :table => klass.table.table_name, :id => child.id
		     )
      if processed.include?(child)
	ret += "<li>#{link} (...recursive...)</li>"
      else
	if processed.length > 10
	  ret += "<li>#{link} (...too deep...)</li>"
	else
	  if child.class == GenericRecord
	    ret += "<li>#{link}</li>"
	  else
	    processed.push(child)
	    ret += "<li>#{link}<br> #{children_table(child,processed)}</li>"
	  end
	end
      end
    else
      # n is nil or > 1
      if klass == Message
	link = link_to("#{n or "?"} x #{klass.name}",:action =>'add_condition',
		       :table => Message.table_name, 
		       :column => "meta_type_name", 
		       :operator => '=', 
		       :value => "#{parent.class}",
		       :column2 => "meta_id", 
		       :operator2 => '=',
		       :value2 => "#{parent.id}",
		       :no_default_filter => true)
      else
	link = link_to("#{n or "?"} x #{klass.name}",:action =>'add_condition',
		       :table => klass.table.table_name, 
		       :column => col, 
		       :operator => '=', 
		       :value => parent.id,
		       :no_default_filter => true)
      end
      ret += "<li>#{link}</li>"
    end

    ret += "</ul>"
    ret
  end

  COUNT_LIMIT = 10000

  def count_cache
    session[@state_id][:count_cache] = {} unless session[@state_id][:count_cache]
    return session[@state_id][:count_cache] 
  end

  def save_value_in_cache(name, value)
    c = count_cache
    c[name] = value
    session[@state_id][:count_cache] = c
  end

  def count_fast(conditions = nil)
    return count_cache[conditions] if count_cache[conditions]

    unless conditions
      if @table_class.respond_to?(:approx_count)
	approx = @table_class.approx_count || 0
	if approx > COUNT_LIMIT
	  return approx
	else
	  return @table_class.count
	end
      end
    end    
    return nil
  end
  
  def count_slow(conditions = nil)
    fast = count_fast(conditions)
    return fast if fast
    value = current_table.count(:conditions => conditions)
    save_value_in_cache(conditions,value)
    return value
  end
 
  ## OLD CODE
  #  def compute_percentage(pos_condition, neg_condition, divisor_condition, default_value)
  #    return [ default_value] unless
  #      pos_condition or neg_condition or divisor_condition
  #    pos_count = get_count_from_cache_or_compute(pos_condition)
  #    neg_count = get_count_from_cache_or_compute(neg_condition)
  #    divisor = get_count_from_cache_or_compute(divisor_condition)
  #    
  #    ret = 0
  #    ret += pos_count unless pos_count == nil
  #    ret -= neg_count unless neg_count == nil
  #    if divisor then
  #      if divisor == 0
  #	ret = "INF"
  #      else
  #	ret = ret.to_f / divisor.to_f
  #	ret = (ret * 1000).round.to_f / 10
  #      end
  #    end
  #    
  #    return [ret, pos_count, neg_count, divisor]
  #  end
    
#  def count
#    if params[:fast] 
#      count_fast()
#    else
#      count_slow() 
#    end
#  end 

  def get_count_text
    cs = get_condition_string
    approx_text = ""
    unless params[:slow_count] 
      approx_text = "Approximate/cached values! "
      total_count = count_fast()
      now_count = count_fast(cs)
    else
      total_count = count_fast()
      now_count = count_slow(cs)
    end    

    ret = ""
    if total_count
      ret += approx_text + "There are total #{pluralize(total_count,'record')}."
    end      
    if now_count
      ret += " You have selected #{pluralize(now_count,'record')}"
    end
    if total_count and total_count > 0 and now_count
      ret += " (#{((now_count.to_f / total_count.to_f * 1000).round().to_f/10)}%)" 
    end
    return ret
  end

  #    # Code for pagination with a query
  #    if @all_count != @count_limit then
  #      @display_count = "#{@current_count} records of #{@all_count.to_i} (#{if @all_count > 0 then ((@current_count.to_f / @all_count.to_f * 1000).round().to_f/10) else 0 end})"
  #    else
  #      @display_count = "More than #{@count_limit} records..."
  #    end    

  
  ## OLD CODE
  ## for c_num in 0...@conditions.length
  ## @raw_descriptions = get_desc(c_num)
  ## @descriptions[c_num] = []
  ## #for d_num in 0...@raw_descriptions.length
  ## #  desc = @raw_descriptions[d_num]
  ## 
  ## #  @descriptions[c_num][d_num] = [desc ] +
  ##     compute_percentage(desc[2],desc[3],desc[4], desc[5])
  ## #end

  def format_column(record,column, index)
    ret = ""
    val = record.send(column.name)
    hash = "#{val}_#{column.name}_#{index}".hash.abs
    if !val.nil? and val.class == String
      sub_num = 0
      val.gsub(/\d+\.\d+\.\d+\.\d+/) {|v|
	sub_num += 1
	table_id = "ip_#{hash}_#{sub_num}"
	ranges = IpRange.find_including_range(v)	
	ip = v.to_ip
	
	if ranges.length > 0
	  ret += fobj(ranges[0],"show","<span #{show_hide(table_id)}>#{v}</span>")
	else
	  ret += "<span #{show_hide(table_id)}>#{v}</span>"
	end
	ret += "<div style='position:absolute;'><div #{show_hide_element(table_id)}'> <table>"
	ret += "<tr>"
	ret += "<td rowspan='#{ranges.length * 5 + 1}'>"
	ret += "A:&nbsp;#{h(v)}<br/>"
	ret += "I:&nbsp;#{ip.to_i.to_s }<br>"
	ret += "DIG:#{ip.dig}<br/>"
	ret += "</td>"
	ret += "</tr>"
	ranges.each {|ipr|
	  ret += "<tr><th>#{fobj(ipr)}</th></tr>"
	  
	  if ipr.single_ip?
	    ret += "<tr><td>#{ipr.description}</td></tr>"	  
	  else
	    ret += "<tr><td>#{ipr.description}</td></tr>"	  
	    ret += "<tr><td>#{ipr.from_ip} - #{ipr.to_ip}</td></tr>"
	    ret += "<tr><td>range contains #{ipr.to_ip.to_i - ipr.from_ip.to_i} ips</td></tr>"
	    ret += "<tr><td>the ip is number #{ip.to_i- ipr.from_ip.to_i + 1} in range</td></tr>"
	  end
	}
	ret += "</table></div></div>"
	ret
      }
    else
      h(record.send(column.name)) 
    end
  rescue
    if RAILS_ENV == "development"
      "#{h(record[column.name])} <span class='error'>#{$!}</span>" 
    else
      "<span class='error'>#{h(record[column.name])}</span>" 
    end
  end

end
