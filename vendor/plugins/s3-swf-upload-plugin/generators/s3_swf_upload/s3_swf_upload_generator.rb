require File.expand_path(File.dirname(__FILE__) + "/lib/insert_routes.rb")

class S3SwfUploadGenerator < Rails::Generator::Base
  def initialize(runtime_args, runtime_options = {})
    super
  end

  def manifest
    record do |m|
      m.file 'controller.rb', 'app/controllers/s3_uploads_controller.rb'
      m.file 'amazon_s3.yml', 'config/amazon_s3.yml'
      m.file 'initializer.rb', 'config/initializers/s3_upload.rb'
      m.file 's3_upload.js', 'public/javascripts/s3_upload.js'
      m.file 's3_upload.swf', 'public/s3_upload.swf'
      FileUtils.mkdir_p('lib/tasks')
      m.file 's3_swf.rake',   'lib/tasks/s3_swf.rake'
      m.file 'crossdomain.xml', 'lib/tasks/crossdomain.xml'
      m.route_resources 's3_uploads'
    end
  end
end

