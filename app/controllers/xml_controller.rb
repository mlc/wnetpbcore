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

      havezip = MIME::Types.of(params[:xml].original_filename).any?{|t| t.content_type == "application/zip"}
      if havezip
        successes = 0
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
              a.save unless a.merge_existing
              successes += 1
            else
              failures << "#{entry.name} is not valid"
            end
          rescue Exception => e
            failures << "#{e.to_s} on #{entry.name}"
          end
        end
        flash.now[:message] = "#{successes} #{successes == 1 ? "record" : "records"} imported"
        flash.now[:warning] = failures.join(", ") unless failures.empty?
      else
        begin
          a = Asset.from_xml(params[:xml].read)
          if a.valid?
            a.destroy_existing
            if (other = a.merge_existing)
              flash.now[:message] = "merged with #{other.title}"
            else
              a.save
              flash.now[:message] = "thanks for #{a.title}"
            end
          else
            flash.now[:error] = "Sorry, couldn't import that record: <ul>" + a.errors.full_messages.map{|err| "<li>#{err}</li>"}.join + "</ul>"
            raise ActiveRecord::Rollback
          end
        rescue Exception => e
          flash.now[:error] = "We're sorry, an error occurred importing that record."
          logger.error e
        end
      end
    elsif request.put?
      respond_to do |format|
        format.xml do
          unless params[:xml] && !params[:xml].empty?
            render :xml => "<message severity='error'>no XML provided.</message>" and return
          end
          a = Asset.from_xml(params[:xml])
          if a.valid?
            a.destroy_existing
            if (other = a.merge_existing)
              render :xml => other.to_xml
            else
              a.save
              render :xml => a.to_xml
            end
          else
            render :xml => "<message severity='error'>sorry, couldn't import.</message>"
            raise ActiveRecord::Rollback
          end
        end
      end
    end
  end
end
