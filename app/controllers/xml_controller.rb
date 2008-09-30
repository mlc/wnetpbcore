class XmlController < ApplicationController
  def index
    @page_title = "Upload XML"
    if request.post?
      begin
        a = Asset.from_xml(params[:xml].read)
        a.save
        flash[:message] = "thanks for #{a.titles[0].title}"
      rescue Exception => e
        flash[:error] = e.to_s
      end
    end
  end
end
