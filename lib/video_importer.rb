module Importers
  STYLESHEET = LibXSLT::XSLT::Stylesheet.new(XML::Document.file(File.join(RAILS_ROOT, 'lib', 'mediainfo_2_pbcore_inst.xsl')))

  def self.mediainfo_instantiation(path)
    xml_str = `mediainfo --Full --Language=raw --Output=XML "#{path}"`
    raise "mediainfo failed" if $?.exitstatus != 0

    xml_doc = XML::Document.string(xml_str)
    inst_xml = STYLESHEET.apply(xml_doc)
    Instantiation.from_xml(inst_xml)
  end

  class VideoImportJob < Struct.new(:asset_id, :upload_path)
    def perform
      asset = Asset.find(asset_id)
      s3obj = AWS::S3::S3Object.find(upload_path, S3SwfUpload::S3Config.bucket)

      instantiation = Importers.mediainfo_instantiation(s3obj.url)
      base_path = upload_path.split('/').last

      instantiation.format_ids << FormatId.new(:format_identifier => base_path, :format_identifier_source => FormatIdentifierSource::OUR_ONLINE_SOURCE)
      instantiation.format_location = upload_path
      instantiation.format = FormatDigital.find_or_create_by_name(s3obj.content_type) # should always be video/mp4...

      # now make the object public, so cloudfront can get to it.
      s3obj.acl.grants << AWS::S3::ACL::Grant.grant(:public_read)
      s3obj.acl(s3obj.acl)

      # and save everything...
      asset.instantiations << instantiation
      asset.save
      Sunspot.index!(asset)
    end
  end

  class ImageImportJob < Struct.new(:asset_id, :image_path)
    SIZES = {
      :thumb => ["80x60", "white"]
      :preview => ["640x480", "black"]
    }

    def perform
      uuid = UUID.random_create.to_s

      instantiation = Importers.mediainfo_instantiation(image_path)
      instantiation.format_ids.reject!{|fid| fid.format_identifier_source.name = "File Name"}
      instantiation.format_location = instantiation.uuid = uuid
      instantiation.format_ids << FormatId.new(:format_identifier => uuid, :format_identifier_source => FormatIdentifierSource::OUR_THUMBNAIL_SOURCE)

      s3orig = AWS::S3::S3Object.store("#{uuid}/original", File.read(image_path), S3SwfUpload::S3Config.bucket)

      SIZES.each do |size, opts|
        image = MiniMagick::Image.from_file(image_path)
        image.combine_options do |c|
          dims, color = opts

          c.thumbnail "#{dims}>"
          c.background color
          c.gravity "center"
          c.extent dims
        end
        AWS::S3::S3Object.store("#{uuid}/#{size}", image.to_blob, S3SwfUpload::S3Config.bucket, :content_type => 'image/jpeg')
      end

      asset = Asset.find(asset_id)
      asset.instantiations << instantiation
      asset.save
      Sunspot.index!(asset)

      File.unlink(image_path)
    end
  end

end
