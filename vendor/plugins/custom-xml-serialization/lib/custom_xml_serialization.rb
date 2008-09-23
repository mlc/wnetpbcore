require 'active_record'
require 'active_support/inflector'

# Adds the ability for an +ActiveRecord+ instance to specify exactly what fields
# get included when it's XML-serialized.

module CustomXMLSerialization
  
  # Attaches this module's functionality to a class when it's included.
  
  def self.included(mod)
    mod.extend(ClassMethods)
  end
  
  module ClassMethods

    # Indicates the attributes to be serialized, as an ordered array.
    # Attributes can be simple symbols (e.g., <tt>:name</tt>) or hashes
    # representing second-level associated attributes (e.g., <tt>{ :person =>
    # :name }</tt>). Operation is undefined if any hash has more than one
    # key/value pair.
    #
    # This method should be called only once per class. If a subclass calls this
    # method, it cannot simply extend the list of serializable parameters; it
    # must redefine the entire list.

    def xml_serialize(*attributes)
      eval_string = <<-EOL
        def to_xml(options = {})
          #TODO if I put "super" in here, can I chain-call xml_serialize in my subclasses to append new parameters?
          options[:indent] ||= 2
          xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
          xml.instruct! unless options[:skip_instruct]
          options[:skip_instruct] = true
          args = options[:dasherize] == false ?
            [ (options[:root] || self.class.to_s.underscore).to_s ] :
            [ (options[:root] || self.class.to_s.underscore).to_s.dasherize ]
          args << { :xmlns => options[:namespace] } if options[:namespace]
          
          if options[:only] then
            only_array = if options[:only].kind_of? Array then options[:only] else [ options[:only] ] end
            only_array.map! { |m| m.to_sym }
          else
            only_array = nil
          end
          if options[:except] then
            except_array = if options[:except].kind_of? Array then options[:except] else [ options[:except] ] end
            except_array.map! { |m| m.to_sym }
          else
            except_array = nil
          end
          
          xml.tag!(*args) do
      EOL
      unless attributes.kind_of? Array
        attributes = [ attributes ]
      end
      attributes.each do |attribute|
        if attribute.kind_of? Hash then
          first = attribute.keys.first.to_s
          second = attribute.values.first
          if second.kind_of? Array then
            tag_name = second.last.to_s
            eval_string << "            unless (only_array and !only_array.include?(\"#{tag_name}\".to_sym)) or (except_array and except_array.include?(\"#{tag_name}\".to_sym))\n"
            eval_string << "              xmlify_with_options xml, \"#{tag_name}\", (if #{first} then #{first}.#{second.first.to_s} else nil end), options.merge(@@xml_serialization_options[\"#{tag_name}\"])\n"
            eval_string << "            end\n"
          else
            tag_name = first.to_s + '-' + second.to_s
            eval_string << "            unless (only_array and !only_array.include?(\"#{tag_name}\".to_sym)) or (except_array and except_array.include?(\"#{tag_name}\".to_sym))\n"
            eval_string << "              xmlify_with_options xml, \"#{tag_name}\", (if #{first} then #{first}.#{second} else nil end), options.merge(@@xml_serialization_options[\"#{tag_name}\"])\n"
            eval_string << "            end\n"
          end
        elsif attribute.kind_of? Array then
          tag_name = attribute.last.to_s
          eval_string << "            unless (only_array and !only_array.include?(\"#{tag_name}\".to_sym)) or (except_array and except_array.include?(\"#{tag_name}\".to_sym))\n"
          eval_string << "              xmlify_with_options xml, \"#{tag_name}\", #{attribute.first.to_s}, options.merge(@@xml_serialization_options[\"#{tag_name}\"])\n"
          eval_string << "            end\n"
        else
          tag_name = attribute.to_s
          eval_string << "            unless (only_array and !only_array.include?(\"#{tag_name}\".to_sym)) or (except_array and except_array.include?(\"#{tag_name}\".to_sym))\n"
          eval_string << "              xmlify_with_options xml, \"#{tag_name}\", #{attribute.to_s}, options.merge(@@xml_serialization_options[\"#{tag_name}\"])\n"
          eval_string << "            end\n"
        end
      end
      eval_string << <<-EOL
            if include_associations = options.delete(:include)
              root_only_or_except = { :except => options[:except],
                                      :only => options[:only] }

              include_has_options = include_associations.is_a?(Hash)

              for association in include_has_options ? include_associations.keys : Array(include_associations)
                association_options = include_has_options ? include_associations[association] : root_only_or_except

                opts = options.merge(association_options)

                case self.class.reflect_on_association(association).macro
                when :has_many, :has_and_belongs_to_many
                  records = self.send(association).to_a
                  unless records.empty?
                    tag = @@xml_serialization_options[association.to_s][:name]
                    tag ||= records.first.class.to_s.underscore.pluralize
                    tag = tag.dasherize unless options[:dasherize] == false

                    xml.tag!(tag) do
                      if @@xml_serialization_options[association.to_s][:name] and !@@xml_serialization_options[association.to_s][:favor_association_name] then
                        records.each { |r| r.to_xml(opts.merge(:root => @@xml_serialization_options[association.to_s][:name].to_s.singularize)) }
                      elsif @@xml_serialization_options[association.to_s][:favor_class_name] then
                        records.each { |r| r.to_xml(opts) }
                      else
                        records.each { |r| r.to_xml(opts.merge(:root => association.to_s.singularize)) }
                      end
                    end
                  end
                when :has_one, :belongs_to
                  if record = self.send(association)
                    record.to_xml(opts.merge(:root => association))
                  end
                end
              end

              options[:include] = include_associations
            end
          end
        end
      EOL
      class_eval eval_string
    end
  end
end

# Ensures that all +ActiveRecord+ classes have the custom XML serialization
# functionality.

ActiveRecord::Base.class_eval do
  @@xml_serialization_options = Hash.new(Hash.new)
  @@xml_array_serialization_options = Hash.new
  
  def self.xml_serialization_options(field, params)
    @@xml_serialization_options[field.to_s] = params
  end
  
  def self.xml_array_serialization_options(params)
    @@xml_array_serialization_options = params
  end
  
  def self.xml_root
    @@xml_array_serialization_options[:name]
  end
  
  def self.favor_class_names
    @@xml_array_serialization_options[:favor_class_name] != nil
  end
  
  include CustomXMLSerialization
end

class ActiveRecord::Base
  def xmlify_with_options(xml, in_name, in_data, options)
    tag_name = if options[:dasherize] == false then
      in_name.to_s
    else
      in_name.to_s.dasherize
    end
        
    tag_data = if in_data.respond_to? :xmlschema then
      in_data.xmlschema
    else
      in_data.to_s
    end
    
    if options[:cdata] and in_data then
      xml.tag!(tag_name) { |b| b.cdata! tag_data }
    else
      xml.tag!(tag_name, tag_data)
    end
  end
end

class Array
  def to_xml(options={})
    raise "Not all elements respond to to_xml" unless all? { |e| e.respond_to? :to_xml }
    
    options[:root]     ||= all? { |e| e.class.respond_to?(:xml_root) ? e.class.xml_root : nil } ? first.class.xml_root : nil
    options[:root]     ||= all? { |e| e.is_a?(first.class) && first.class.to_s != "Hash" } ? first.class.to_s.underscore.pluralize : "records"
    favor_local_root = !options.key?(:children)
    options[:children] ||= options[:root].singularize
    options[:indent]   ||= 2
    options[:builder]  ||= Builder::XmlMarkup.new(:indent => options[:indent])
  
    root     = options.delete(:root).to_s
    children = options.delete(:children)
  
    if !options.has_key?(:dasherize) || options[:dasherize]
      root = root.dasherize
    end
  
    options[:builder].instruct! unless options.delete(:skip_instruct)
    
    opts = options.merge({ :root => children })
  
    xml = options[:builder]
    if empty?
      xml.tag!(root, options[:skip_types] ? {} : {:type => "array"})
    else
      xml.tag!(root, options[:skip_types] ? {} : {:type => "array"}) {
        yield xml if block_given?
        each do |e|
          opts.merge!(:root => nil) if favor_local_root and e.class.respond_to?(:favor_class_names) and e.class.favor_class_names
          e.to_xml(opts.merge!({ :skip_instruct => true }))
        end
      }
    end
  end
end
