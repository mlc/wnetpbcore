require File.dirname(__FILE__) + '/../test_helper'

class AssetTest < Test::Unit::TestCase
  def test_import
    xml = File.read('test/fixtures/1-3-simple.xml')
    assert @asset = Asset.from_xml(xml)
    assert @asset.valid?
    assert @asset.save
  end

  def test_junk_import
    # yes this is too long of a test. deal.
    xml = File.read("#{RAILS_ROOT}/test/fixtures/pbcore_1_2_full_of_junk.xml")
    assert @asset = Asset.from_xml(xml)
    assert @asset.valid?
    assert @asset.save

    assert_equal 2, @asset.identifiers.size
    assert_equal 2, @asset.titles.size
    assert_equal 2, @asset.subjects.size
    assert_equal 2, @asset.descriptions.size
    assert_equal 2, @asset.genres.size
    assert_equal 2, @asset.relations.size
    assert_equal 2, @asset.coverages.size
    @asset.coverages.each do |coverage|
      assert_equal "Spatial", coverage.coverage_type
    end
    assert_equal 2, @asset.audience_levels.size
    assert_equal 2, @asset.audience_ratings.size
    assert_equal 2, @asset.creators.size
    assert_equal 2, @asset.publishers.size
    assert_equal 2, @asset.rights_summaries.size
    assert_equal 2, @asset.instantiations.size
    @asset.instantiations.each do |instantiation|
      assert_equal 2, instantiation.format_ids.size
      assert_not_empty instantiation.date_created
      assert_not_empty instantiation.date_issued
      assert_not_nil instantiation.format
      assert_not_nil instantiation.format_media_type
      assert_not_nil instantiation.format_generation
      assert_not_empty instantiation.format_file_size
      assert_not_empty instantiation.format_time_start
      assert_not_empty instantiation.format_duration
      assert_not_empty instantiation.format_data_rate
      assert_not_nil instantiation.format_color
      assert_not_empty instantiation.format_tracks
      assert_not_empty instantiation.format_channel_configuration
      assert_not_empty instantiation.language
      assert_not_empty instantiation.alternative_modes
      assert_equal 2, instantiation.essence_tracks.size
      assert_equal 2, instantiation.date_availables.size
      assert_equal 2, instantiation.annotations.size
    end
    assert_equal 2, @asset.extensions.size

    loaded_assets = Asset.find_all_by_uuid(@asset.uuid)
    assert_equal 1, loaded_assets.size
    loaded_asset = loaded_assets.first
    assert_equal 1, loaded_asset.versions.size

    generated_xml = loaded_asset.to_xml
    parser = LibXML::XML::Parser.string(generated_xml)
    parsed_xml = parser.parse
    assert_equal 3, parsed_xml.find("pbcore:pbcoreIdentifier", PbcoreXmlElement::PBCORE_NAMESPACE).size # two included plus one generated
    assert_equal 6, parsed_xml.find("pbcore:pbcoreInstantiation/pbcore:pbcoreFormatID", PbcoreXmlElement::PBCORE_NAMESPACE).size
    assert_equal "audienceRating0", parsed_xml.find_first("//pbcore:audienceRating", PbcoreXmlElement::PBCORE_NAMESPACE).content
    assert_equal ["publisher0", "publisher1"], parsed_xml.find("//pbcore:publisher", PbcoreXmlElement::PBCORE_NAMESPACE).map(&:content)
    assert_equal ["contributorRole0", "contributorRole1"], parsed_xml.find("//pbcore:contributorRole", PbcoreXmlElement::PBCORE_NAMESPACE).map(&:content)
    assert_equal ["genre0", "genre1"], parsed_xml.find("pbcore:pbcoreGenre/pbcore:genre", PbcoreXmlElement::PBCORE_NAMESPACE).map(&:content)
    assert_equal ["genreAuthorityUsed0", "genreAuthorityUsed1"], parsed_xml.find("pbcore:pbcoreGenre/pbcore:genreAuthorityUsed", PbcoreXmlElement::PBCORE_NAMESPACE).map(&:content)
  end
end
