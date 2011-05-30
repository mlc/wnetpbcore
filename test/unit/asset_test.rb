require 'test_helper'

class AssetTest < Test::Unit::TestCase
  def test_import
    xml = File.read('test/fixtures/1-3-simple.xml')
    assert @asset = Asset.from_xml(xml)
    assert @asset.valid?
    assert @asset.save
  end
end
