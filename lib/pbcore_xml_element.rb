module PbcoreXmlElement
  PBCORE_NAMESPACE = "pbcore:http://www.pbcore.org/PBCore/PBCoreNamespace.html"

  module ClassMethods
    def xml_string(attr, field)
      from_xml_elt do |record|
        elts = record._working_xml.find("pbcore:#{attr}", PBCORE_NAMESPACE)
        unless elts.empty? || elts[0].child.empty?
          record.send("#{field}=".to_sym, elts[0].child.to_s)
        end
      end
    end

    def xml_picklist(attr, field, klass)
      from_xml_elt do |record|
        elts = record._working_xml.find("pbcore:#{attr}", PBCORE_NAMESPACE)
        unless elts.empty? || elts[0].child.empty?
          record.send("#{field}=".to_sym, klass.find_or_create_by_name(elts[0].child.to_s))
        end
      end
    end
    
    def xml_subelements(attr, field, klass)
      from_xml_elt do |record|
        elts = record._working_xml.find("pbcore:#{attr}", PBCORE_NAMESPACE)
        record.send("#{field}=".to_sym, elts.map{|elt| klass.from_xml(elt)})
      end
    end
    
    def from_xml(xml)
      if xml.is_a?(String)
        parser = XML::Parser.new
        parser.string = xml
        xml = parser.parse.root
      end
      obj = new
      obj._working_xml = xml
      obj.run_callbacks(:from_xml_elt)
      obj
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
    base.send :include, ActiveSupport::Callbacks
    base.send :attr_accessor, :_working_xml
    base.define_callbacks :from_xml_elt, :to_xml_elt
  end
end
