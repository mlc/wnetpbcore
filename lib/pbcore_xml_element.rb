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
          if record._inline_attributes
            attr_array = record._inline_attributes.keys.map do |ia| 
              [record._inline_attributes[ia][:tag_name], record._inline_attributes[ia][:value]]
            end.flatten
          else
            attr_array = []
          end
          builder.tag!(attr, value, Hash[*attr_array])
        end
      end
    end
    
    def xml_attribute(attr, xml_attr_name)
      to_xml_elt do |record|
        record._inline_attributes ||= {}
        record._inline_attributes[attr] = {:tag_name => xml_attr_name}
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
        result = record.send(field)
        if record._inline_attributes
          record._inline_attributes[attr][:value] = result.is_a?(klass) ? result.name : result
        else
          builder = record._working_xml
          builder.tag!(attr, result.name) if result.is_a?(klass)
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
          builder.tag!(attr) do
            item.build_xml(builder)
          end
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
          builder.tag!(attr1) do
            builder.tag!(attr2, item.name)
          end
        end
      end
    end
    
    def from_xml(xml)
      if xml.is_a?(String)
        parser = XML::Parser.new
        parser.string = xml
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
  def xml_output
    xml=Builder::XmlMarkup.new
    build_xml(xml)
    xml.target!
  end

  def doing_xml?
    !(_working_xml.nil?)
  end
  
  def self.included(base)
    base.extend(ClassMethods)
    base.send :include, ActiveSupport::Callbacks
    base.send :attr_accessor, :_working_xml
    base.send :attr_accessor, :_inline_attributes
    base.define_callbacks :from_xml_elt, :to_xml_elt
  end
end
