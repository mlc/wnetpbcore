class VideoImportJob < Struct.new(:asset_id, :upload_path)
  STYLESHEET = LibXSLT::XSLT::Stylesheet.new(XML::Document.file(File.join(RAILS_ROOT, 'lib', 'mediainfo_2_pbcore_inst.xsl')))

  def perform
    asset = Asset.find(asset_id)
    s3obj = AWS::S3::S3Object.find(upload_path, S3SwfUpload::S3Config.bucket)

    xml_str = `mediainfo --Output=XML "#{s3obj.url}"`
    raise "mediainfo failed" if $?.exitstatus != 0

    base_path = upload_path.split('/').last

    xml_doc = XML::Document.string(xml_str)
    inst_xml = STYLESHEET.apply(xml_doc)
    instantiation = Instantiation.from_xml(inst_xml)

    instantiation.format_ids << FormatId.new(:format_identifier => base_path, :format_identifier_source => FormatIdentifierSource::OUR_ONLINE_SOURCE)
    instantiation.format_location = upload_path
    instantiation.format = FormatDigital.find_or_create_by_name(s3obj.content_type) # should always be video/mp4...

    # mediainfo gives us back the URL we gave it, but this is a secret!
    instantiation.annotations.reject!{|ann| ann.annotation =~ /^Complete.name/}

    # now make the object public, so cloudfront can get to it.
    s3obj.acl.grants << AWS::S3::ACL::Grant.grant(:public_read)
    s3obj.acl(s3obj.acl)

    # and save everything...
    asset.instantiations << instantiation
    asset.save
  end
end
