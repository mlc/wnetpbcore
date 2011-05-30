require 'test_helper'

class PbcoreXmlElementTest < Test::Unit::TestCase
  def setup
    @xml = Builder::XmlMarkup.new(:indent=>0)
  end
  
  def test_xml_element
    t = Title.new(:title=>'testing')
    assert_equal '<title>testing</title>', t.xml_output
  end
  
  def test_nested_xml_element
    t = Title.create!(:title=>'Hello', :title_type => TitleType.create(:name=>'The Type'))
    assert_equal "<title>Hello</title><titleType>The Type</titleType>", t.xml_output
  end
end
