module PbcoreXmlElement
  PBCORE_NAMESPACE = "pbcore:http://www.pbcore.org/PBCore/PBCoreNamespace.html"

  module ClassMethods
    def xml_string(attr, field=nil)
      field ||= attr.underscore.to_sym
      from_xml_elt do |record|
        elts = record._working_xml.find("pbcore:#{attr}", PBCORE_NAMESPACE)
        unless elts.empty? || elts[0].child.nil?
          record.send("#{field}=".to_sym, elts[0].content)
        end
      end
      to_xml_elt do |record|
        builder = record._working_xml
        value = record.send(field)
        unless value.nil? || value.empty?
          builder << XML::Node.new(attr, value)
        end
      end
    end
    
    def xml_attribute(attr, field=nil)
      field ||= attr.underscore.to_sym
      from_xml_elt do |record|
        xmlattr = record._working_xml[attr]
        unless xmlattr.nil?
          record.send("#{field}=".to_sym, xmlattr)
        end
      end
      to_xml_elt do |record|
        xml = record._working_xml
        value = record.send(field)
        xml[attr] = value unless value.nil? || value.empty?
      end
    end
    
    def xml_picklist(attr, field=nil, klass=nil)
      field ||= attr.underscore.to_sym
      klass ||= field.to_s.camelize.constantize
      from_xml_elt do |record|
        elts = record._working_xml.find("pbcore:#{attr}", PBCORE_NAMESPACE)
        unless elts.empty? || elts[0].child.nil?
          record.send("#{field}=".to_sym, klass.find_or_create_by_name(elts[0].child.content))
        end
      end
      to_xml_elt do |record|
        builder = record._working_xml
        result = record.send(field)
        if result.is_a?(klass)
          builder << XML::Node.new(attr, result.name)
        end
      end
    end
    
    def xml_picklist_attribute(attr, field=nil, klass=nil)
      field ||= attr.underscore.to_sym
      klass ||= field.to_s.camelize.constantize
      from_xml_elt do |record|
        xmlattr = record._working_xml[attr]
        unless xmlattr.nil?
          record.send("#{field}=".to_sym, klass.find_or_create_by_name(xmlattr))
        end
      end
      to_xml_elt do |record|
        xml = record._working_xml
        value = record.send(field)
        if value.is_a?(klass)
          xml[attr] = value.name
        end
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
  end

  def build_xml(builder)
    self._working_xml = builder
    #builder.comment! created_string if respond_to?(:created_at)
    #builder.comment! updated_string if respond_to?(:updated_at)
    run_callbacks(:to_xml_elt)
    self._working_xml = nil
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
    $stderr.puts doc.to_s(:indent => false)
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
