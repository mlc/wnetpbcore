# -*- ruby -*-

RAILS_ROOT ||= ENV["RAILS_ROOT"]

namespace :bundle do
  desc "Bundle JS and CSS files"
  task :all => [ :js, :css ]

  desc "Bundle JS files"
  task :js do
    compression_method = "closure"

    require 'lib/js_minimizer' if compression_method != "closure"
    closure_path = RAILS_ROOT + '/lib/jars/closure_compressor.jar'

    paths = get_top_level_directories('/public/javascripts')

    targets = []
    paths.each do |bundle_directory|
      bundle_name = bundle_directory.gsub(RAILS_ROOT + '/public/javascripts/', "")
      files = recursive_file_list(bundle_directory, ".js")
      next if files.empty? || bundle_name == 'dev'
      target = RAILS_ROOT + "/public/javascripts/bundle_#{bundle_name}.js"

      if compression_method == "closure"
        `java -jar #{closure_path} --js #{files.join(" --js ")} --js_output_file #{target}`
      else
        File.open(target, 'w+') do |f|
          f.puts JSMinimizer.minimize_files(*files)
        end
      end
      targets << target
    end

    targets.each do |target|
      puts "=> bundled js at #{target}"
    end
  end

  desc "Bundle CSS files"
  task :css do
    yuipath = RAILS_ROOT + '/lib/jars/yuicompressor-2.4.2.jar'

    paths = get_top_level_directories('/public/stylesheets')

    targets = []
    paths.each do |bundle_directory|
      bundle_name = bundle_directory.gsub(RAILS_ROOT + '/public/stylesheets/', "")
      files = recursive_file_list(bundle_directory, ".css")
      next if files.empty? || bundle_name == 'dev'

      bundle = ''
      files.each do |file_path|
        bundle << File.read(file_path) << "\n"
      end

      target = RAILS_ROOT + "/public/stylesheets/bundle_#{bundle_name}.css"
      rawpath = "/tmp/bundle_raw.css"
      File.open(rawpath, 'w') { |f| f.write(bundle) }
      `java -jar #{yuipath} --line-break 0 #{rawpath} -o #{target}`

      targets << target
    end

    targets.each do |target|
      puts "=> bundled css at #{target}"
    end
  end

  require 'find'
  def recursive_file_list(basedir, ext)
    files = []
    Find.find(basedir) do |path|
      if FileTest.directory?(path)
        if File.basename(path)[0] == ?. # Skip dot directories
          Find.prune
        else
          next
        end
      end
      files << path if File.extname(path) == ext
    end
    files.sort
  end

  def get_top_level_directories(base_path)
    Dir.entries(RAILS_ROOT + base_path).collect do |path|
      path = RAILS_ROOT + "#{base_path}/#{path}"
      File.basename(path)[0] == ?. || !File.directory?(path) ? nil : path # not dot directories or files
    end - [nil]
  end
end
