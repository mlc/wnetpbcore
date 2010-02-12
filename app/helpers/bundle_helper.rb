require 'find'
module BundleHelper
  AJAX_LIBRARIES = {
    :jquery => ['jquery-1.4.1.min', 'https://ajax.googleapis.com/ajax/libs/jquery/1.4.1/jquery.min.js'],
    :jquery_ui => ['jquery-ui-1.7.2.min', 'http://ajax.googleapis.com/ajax/libs/jqueryui/1.7.2/jquery-ui.min.js'],
    :swfobject => ['swfobject', 'http://ajax.googleapis.com/ajax/libs/swfobject/2.2/swfobject.js']
  }.freeze

  def bundle_files?
    RAILS_ENV == 'production' || params[:bundle] || cookies[:bundle] == "yes"
  end

  def javascript_bundle(*sources)
    sources = sources.to_a
    bundle_files? ? javascript_include_bundles(sources) : javascript_include_files(sources)
  end

  # This method assumes you have manually bundled js using a rake command
  # or similar. So there better be bundle_* files.
  def javascript_include_bundles(bundles)
    output = ""
    bundles.each do |bundle|
      output << javascript_src_tag("bundle_#{bundle}", {}) + "\n"
    end
    output
  end

  def javascript_include_files(bundles)
    output = ""
    bundles.each do |bundle|
      files = recursive_file_list("public/javascripts/#{bundle}", ".js")
      files.each do |file|
        file = file.gsub('public/javascripts/', '')
        output << javascript_src_tag(file, {}) + "\n"
      end
    end
    output
  end

  def javascript_dev(*sources)
    output = ""
    sources = sources.to_a
    sources.each do |pair|
      output << javascript_src_tag(RAILS_ENV == 'development' ? "dev/#{pair[0]}" : pair[1], {})
    end
    output
  end

  def stylesheet_bundle(*sources)
    sources = sources.to_a
    bundle_files? ? stylesheet_include_bundles(sources) : stylesheet_include_files(sources)
  end

  # This method assumes you have manually bundled css using a rake command
  # or similar. So there better be bundle_* files.
  def stylesheet_include_bundles(bundles)
    stylesheet_link_tag(bundles.collect{ |b| "bundle_#{b}"})
  end

  def stylesheet_include_files(bundles)
    output = ""
    bundles.each do |bundle|
      files = recursive_file_list("public/stylesheets/#{bundle}", ".css")
      files.each do |file|
        file = file.gsub('public/stylesheets/', '')
        output << stylesheet_link_tag(file)
      end
    end
    output
  end

  def recursive_file_list(basedir, extname)
    files = []
    basedir = RAILS_ROOT + "/" + basedir
    Find.find(basedir) do |path|
      if FileTest.directory?(path)
        if File.basename(path)[0] == ?.
          Find.prune
        else
          next
        end
      end
      files << path.gsub(RAILS_ROOT + '/', '') if File.extname(path) == extname
    end
    files.sort
  end

  def google_javascript_libraries(flash = false)
    libs = [:jquery, :jquery_ui]
    libs << :swfobject if flash
    javascript_dev(*AJAX_LIBRARIES.values_at(*libs))
  end
end
