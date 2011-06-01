require 'test_helper'

class PbcoreXmlElementTest < Test::Unit::TestCase
  def test_xml_element
    t = Title.new(:title=>'testing')
    assert_equal '<title>testing</title>', t.dummy_xml_output
  end
  
  def test_nested_xml_element
    t = Title.create!(:title=>'Hello', :title_type => TitleType.create(:name=>'The Type'))
    assert_equal "<title>Hello</title><titleType>The Type</titleType>", t.dummy_xml_output
  end
  
  def test_asset_date_attribute_output
    adt = AssetDateType.create!(:name=>'when')
    ad = AssetDate.create!(:asset_date=>'today', :asset_date_type => adt)
    assert_equal '<assetDate dateType="when">today</assetDate>', ad.dummy_xml_output
  end
  
  def test_asset_date_attribute_from_xml
    a = Asset.from_xml(File.read('test/fixtures/asset_date_with_attributes.xml'))
    assert a.valid?
    assert_equal '2010-03-23', a.asset_dates.first.asset_date
    assert_equal 'availableEnd', a.asset_dates.first.asset_date_type.name
  end
end
