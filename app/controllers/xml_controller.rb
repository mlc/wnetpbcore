require 'zip_extensions'

class XmlController < ApplicationController
  def index
    if request.post?
      havezip = MIME::Types.of(params[:xml].original_filename).any?{|t| t.content_type == "application/zip"}
      if havezip
        begin
          ThinkingSphinx.updates_enabled = false
          successes = []
          failures = []
          zip = Zip::ZipInputStream.new(params[:xml])
          while (entry = zip.get_next_entry) do
            next unless entry.file? && entry.size > 0
            next if entry.name =~ /__MACOS/ # attempt to ignore resource fork
            next if entry.name =~ /[\/\\]\.[^\/\\]*/ # and hidden files too
            begin
              a = Asset.from_xml(zip.read(nil, String.new))
              if a.valid?
                a.destroy_existing
                a.save
                successes << a.titles[0].title
              else
                failures << "#{entry.name} is not valid"
              end
            rescue Exception => e
              failures << "#{e.to_s} on #{entry.name}"
            end
          end
        ensure
          ThinkingSphinx.updates_enabled = true
          AssetTerms.async_reindex
        end
        flash.now[:message] = "read " + successes.join(", ")
        flash.now[:warning] = failures.join(", ") unless failures.empty?
      else
        begin
          a = Asset.from_xml(params[:xml].read)
          if a.valid?
            a.destroy_existing
            a.save
            flash.now[:message] = "thanks for #{a.title}"
          else
            flash.now[:error] = "Sorry, couldn't import that record: <ul>" + a.errors.full_messages.map{|err| "<li>#{err}</li>"}.join + "</ul>"
            raise ActiveRecord::Rollback
          end
        rescue Exception => e
          flash.now[:error] = e.to_s
        end
      end
    end
  end
end
