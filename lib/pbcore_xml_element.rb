# This is a set of methods which define a DSL for explaining how a model
# should be transformed between ActiveRecord and PBCore XML.
#
# To understand this code, I unfortunately must at this time recommend
# that you see http://www.catb.org/jargon/html/magic-story.html
module PbcoreXmlElement
  PBCORE_URI = "http://www.pbcore.org/PBCore/PBCoreNamespace.html"
  PBCORE_NAMESPACE = "pbcore:#{PBCORE_URI}"

  module Util
    def self.set_pbcore_ns(node)
      pbcorens = XML::Namespace.new(node, nil, PBCORE_URI)
      node.namespaces.namespace = pbcorens
    end
  end

  module ClassMethods
    def xml_string(attr, field=nil, *args)
      field ||= attr.underscore.to_sym
      attributes = map_to_xml_attributes(args)

      from_xml_elt do |record|
        elts = record._working_xml.find("pbcore:#{attr}", PBCORE_NAMESPACE)
        unless elts.empty? || elts[0].child.nil?
          record.store_string_or_name(field, elts[0].content)
          fetch_attributes(record, elts[0], attributes)
        end
      end
      to_xml_elt do |record|
        builder = record._working_xml
        value = record.string_or_name(field)
        unless value.nil? || value.empty?
          node = XML::Node.new(attr, value)
          store_attributes(record, node, attributes)
          builder << node
        end
      end
    end
    
    def xml_attributes(*args)
      attributes = map_to_xml_attributes(args)
      from_xml_elt do |record|
        fetch_attributes(record, record._working_xml, attributes)
      end
      to_xml_elt do |record|
        store_attributes(record, record._working_xml, attributes)
      end
    end

    def xml_subelements(attr, field, klass=nil)
      klass ||= field.to_s.singularize.camelize.constantize
      from_xml_elt do |record|
        elts = record._working_xml.find("pbcore:#{attr}", PBCORE_NAMESPACE)
        objs = elts.map{|elt| klass.from_xml(elt)}.select{|obj| obj.valid?}
        record.send("#{field}=".to_sym, objs)
      end
      to_xml_elt do |record|
        builder = record._working_xml
        record.send(field).each do |item|
          node = XML::Node.new(attr)
          builder << node
          item.build_xml(node)
        end
      end
    end

    def xml_subelements_picklist(attr1, attr2, field, klass=nil)
      klass ||= field.to_s.singularize.camelize.constantize
      from_xml_elt do |record|
        elts = record._working_xml.find("pbcore:#{attr1}/pbcore:#{attr2}", PBCORE_NAMESPACE)
        elts = elts.select{|elt| !elt.empty? && !elt.child.nil?}
        record.send("#{field}=".to_sym, elts.map{|elt| klass.find_or_create_by_name(elt.child.content)})
      end
      to_xml_elt do |record|
        builder = record._working_xml
        record.send(field).each do |item|
          node = XML::Node.new(attr1)
          builder << node
          node << XML::Node.new(attr2, item.name)
        end
      end
    end

    def from_xml(xml)
      if xml.is_a?(String)
        parser = XML::Parser.string(xml)
        xml = parser.parse.root
      end
      obj = self.new
      obj._working_xml = xml
      obj.run_callbacks(:from_xml_elt)
      obj._working_xml = nil
      obj
    end

    protected
    def map_to_xml_attributes(attr_array)
      attr_array.map do |k|
        if k.is_a?(Hash)
          if k.size != 1
            raise "invalid argument"
          else
            k.first
          end
        else
          [k, k.underscore.to_sym]
        end
      end
    end

    def fetch_attributes(record, node, attributes)
      attributes.each do |name, fld|
        if node[name]
          val = node[name]
          record.store_string_or_name(fld, val) if val
        end
      end
    end

    def store_attributes(record, node, attributes)
      attributes.each do |name, fld|
        val = record.string_or_name(fld)
        node[name] = val unless val.nil? || val.empty?
      end
    end
  end

  def build_xml(builder)
    self._working_xml = builder
    #builder.comment! created_string if respond_to?(:created_at)
    #builder.comment! updated_string if respond_to?(:updated_at)
    run_callbacks(:to_xml_elt)
    self._working_xml = nil
  end

  def string_or_name(field)
    value = self.send(field)
    value.respond_to?(:name) ? value.name : value
  end

  def store_string_or_name(field, value)
    reflect = self.class.reflect_on_association(field)
    value = reflect.klass.find_or_create_by_name(value) if reflect
    self.send("#{field}=".to_sym, value)
  end

  def created_string
    "created at #{created_at.to_s} by #{(creator_id.nil? || record_creator.nil?) ? "unknown" : record_creator.login}"
  end

  def updated_string
    "updated at #{updated_at.to_s} by #{(updater_id.nil? || record_updater.nil?) ? "unknown" : record_updater.login}"
  end
  
  # for unit tests
  def dummy_xml_output
    doc = XML::Document.new
    root = XML::Node.new("DUMMY")
    doc.root = root
    build_xml(root)
    # $stderr.puts doc.to_s(:indent => false)
    /<DUMMY>(.*)<\/DUMMY>/m.match(doc.to_s(:indent => false))[1]
  end

  def doing_xml?
    !(_working_xml.nil?)
  end
  
  def self.included(base)
    base.extend(ClassMethods)
    base.send :include, ActiveSupport::Callbacks
    base.send :attr_accessor, :_working_xml
    base.define_callbacks :from_xml_elt, :to_xml_elt
  end
end
