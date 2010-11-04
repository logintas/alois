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

module Ruport
  
  # This module is designed to be mixed in with an ActiveRecord model
  # to add easy conversion to Ruport's data structures.
  module Reportable
    
    def self.included(base) # :nodoc:
      base.extend ClassMethods  
    end
    
    module ClassMethods 
      
      # In the ActiveRecord model you wish to integrate with Ruport, add the 
      # following line just below the class definition:
      #
      #   acts_as_reportable
      #
      # This will automatically make all the methods in this module available
      # in the model.
      def acts_as_reportable
        include Ruport::Reportable::InstanceMethods
        extend Ruport::Reportable::SingletonMethods
      end
    end
    
    module SingletonMethods
      # Creates a Ruport::Data::Table from an ActiveRecord find. Takes 
      # parameters just like a regular Active find. If you use the :include 
      # option, it will return a table with all columns from the model and 
      # the included associations. If you use the :columns option, it will
      # return a table with only the specified columns. To access a column 
      # in an associated table, use the association in the column name. 
      #
      # Example:
      # 
      # class Book < ActiveRecord::Base
      #   belongs_to :author
      #   acts_as_reportable
      # end
      #
      # Book.report_table(:all, :columns => ['title', 'author.name']).as(:html)
      #
      # Returns: a html version of a report with two columns, title from 
      # the book, and name from the associated author.
      #
    
      # Calling Book.report_table(:all, :include => [:author]).as(:html) will 
      # return a table with all columns from books and authors.
      #
      def report_table(number = :all, options = {})

        options[:include] ||= []
        report_columns = options.delete(:columns)
        report_columns ||= column_names + options[:include].map {|x| reflect_on_association(x).klass.column_names.map {|y| "#{x}.#{y}"}}.flatten
    
        includes, attributes = split_columns report_columns
     
        options[:include] = (options[:include] + includes).uniq
        
        data = find(number,options).map do |r| 
          r.get_attributes_with_associations :only => attributes, 
            :include => options[:include]
        end   
    
        Ruport::Data::Table.new(:data => data, 
          :column_names => report_columns).reorder(report_columns)
      end
 
  
      private 
  
      # Split an array of columns into associations and attributes.
      #
      # Example: split_columns(['title','author.name'])
      # Returns: [:author], ['title','name']
      # 
      def split_columns(columns)
        includes = []
        attributes = []
    
        columns.each do |column|
          include,attribute = column.split(/\./) 
      
          attributes << (attribute || include)
          includes << include.to_sym if attribute      
        end if columns
  
        return includes, attributes
      end
      
    end
    
    module InstanceMethods
      # Instance methods for ActiveRecord objects. Grabs all of the 
      # object's attributes and the attributes of the associated objects
      # and returns them in a hash. Associated object attributes are 
      # stored in the hash with "association.attribute" keys. Passing 
      # :only as an option will only get those attributes. Must pass
      # :include as an option to access associations.
      #
      # Example: 
      # 
      # class Book < ActiveRecord::Base
      #   belongs_to :author
      #   acts_as_reportable
      # end
      # 
      # abook.get_attributes_with_associations(:only => ['title','name'], 
      #                                        :include => [:author])
      # returns: {'title' => 'books title', 
      #           'author.name' => 'authors name', 
      #           'author.title' => 'Mr.', 
      #           'name' => 'book name' }      
      #  
      # NOTE: author.title and name will only be returned if those values 
      # exist in the tables. If the books table does not have a name column,
      # name will not be returned. Likewise, if the authors table does not
      # have a title column, it will not be returned.
      #      
      def get_attributes_with_associations(options = {})
        options[:root] ||= self.class.to_s.underscore        
        root_only_or_except = 
          if options[:only] or options[:except]
            { :only => options[:only], :except => options[:except] }
          else
            nil
          end
        attrs = attributes(root_only_or_except)
        
        if include_associations = options.delete(:include)
          include_has_options = include_associations.is_a?(Hash)

          for association in include_has_options ? include_associations.keys : Array(include_associations)
            association_options = include_has_options ? include_associations[association] : root_only_or_except

            case self.class.reflect_on_association(association).macro

              when :has_many, :has_and_belongs_to_many
                #records = send(association).to_a
                #unless records.empty?
                #  attrs[association] = records.collect do |record| 
                #    record.attributes(association_options)
                #  end
                #end
                
              when :has_one, :belongs_to
                if record = send(association)
                  attrs = record.attributes().inject(attrs) {|h,(k,v)| h["#{association}.#{k}"] = v; h }
                end
            end
          end
        end
        
        attrs
      end
    end
  end
end