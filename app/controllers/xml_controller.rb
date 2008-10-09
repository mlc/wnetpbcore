class XmlController < ApplicationController
  def index
    @page_title = "Upload XML"
    if request.post?
      begin
        a = Asset.from_xml(params[:xml].read)
        a.save
        flash.now[:message] = "thanks for #{a.titles[0].title} #{params[:xml].class}"
      rescue Exception => e
        flash.now[:error] = e.to_s
      end
    end
  end
end
