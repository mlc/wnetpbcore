# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def opensearch_headers(collection = nil)
    msg = tag("link",  {:href=>"/pbcore.opensearch.xml",
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
end
