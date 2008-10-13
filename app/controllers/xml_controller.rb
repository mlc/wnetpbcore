require 'zip_extensions'

class XmlController < ApplicationController
  def index
    @page_title = "Upload XML"
    if request.post?
      havezip = MIME::Types.of(params[:xml].original_filename).any?{|t| t.content_type == "application/zip"}
      if havezip
        successes = []
        zip = Zip::ZipInputStream.new(params[:xml])
        while (entry = zip.get_next_entry) do
          next unless entry.file? && entry.size > 0
          next if entry.name =~ /__MACOS/ # attempt to ignore resource fork
          next if entry.name =~ /[\/\\]\.[^\/\\]*/ # and hidden files too
          #begin
            a = Asset.from_xml(zip.read(nil, String.new))
            a.save
            successes << a.titles[0].title
          #rescue Exception => e
          #  flash.now[:warning] ||= "#{e.to_s} on #{entry.name}"
          #end
        end
        flash.now[:message] = "read " + successes.join(", ")
      else
        begin
          a = Asset.from_xml(params[:xml].read)
          a.save
          flash.now[:message] = "thanks for #{a.titles[0].title}"
        rescue Exception => e
          flash.now[:error] = e.to_s
        end
      end
    end
  end
end