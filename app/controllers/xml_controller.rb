require 'zip_extensions'

class XmlController < ApplicationController

  filter_access_to :index, :context => :assets, :require => :create

  # we want to use our own XML parsing, so let's disable rails'
  param_parsers[Mime::XML] = Proc.new do |data|
    {:xml => data}
  end

  # gah, this method is awful code. no one look at it please. kthxbye.
  def index
    if request.post?
      unless params[:xml] && params[:xml].respond_to?(:original_filename)
        flash[:error] = "You must provide an XML or ZIP file."
        redirect_to :action => :index and return
      end

      counts = [0,[]]

      # If this is a zip file
      if MIME::Types.of(params[:xml].original_filename).any?{|t| t.content_type == "application/zip"}
        zip_file = Zip::ZipInputStream.new(params[:xml])
        while (entry = zip_file.get_next_entry) do
          next unless entry.file? && entry.size > 0
          next if entry.name =~ /__MACOS/ # attempt to ignore resource fork
          next if entry.name =~ /[\/\\]\.[^\/\\]*/ # and hidden files too

          # magical?
          counts = counts.zip(Asset.import_xml(zip_file, entry.name)).map{|x,y| x+y}
        end
      else
        counts = Asset.import_xml(params[:xml].read)
      end

      successes, failures = counts
      if successes.size == 1
        # Get the just uploaded asset and construct a success message with link
        # to newly created record
        asset = Asset.find_by_uuid(successes[0])
        flash.now[:message] = "asset <a href=\"#{asset_path(asset)}\">#{asset.title}</a> imported"
      else
        flash.now[:message] = "#{successes.size} records imported"
      end
      flash.now[:warning] = failures.join(", ") unless failures.empty?

    elsif request.put?
      respond_to do |format|
        format.xml do
          unless params[:xml] && !params[:xml].empty?
            render :xml => "<message severity='error'>no XML provided.</message>" and return
          end
          counts = Asset.import_xml(params[:xml])
          render :xml => (Asset.xmlify_import_results(counts){|uuid| asset_url(uuid)})
        end
      end
    end
  end
end
