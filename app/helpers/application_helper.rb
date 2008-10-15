# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def opensearch_headers(collection = nil)
    msg = tag("link",  {:href=>"/assets/opensearch.xml",
      :rel=>"search",
      :type=>"application/opensearchdescription+xml",
      :title=>"PBCore Search"})
    unless collection.nil?
      opensearch_properties(collection).each do |k,v|
        msg << "\n    " + tag("meta", { "name" => k, "content" => v })
      end
    end
    msg
  end
  
  def opensearch_properties(collection)
    {
      "totalResults" => collection.total_entries,
      "startIndex" => collection.offset + 1,
      "itemsPerPage" => 20
    }
  end
  
  def alternate_views
    @alternates.map{|href,type| tag(:link,:href=>href, :rel=>:alternate, :type=>type, :title=>@page_title)}.join
  end
end
