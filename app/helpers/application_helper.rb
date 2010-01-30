# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def title(title)
    content_for(:title) { title }
  end
  
  def add_navbar(*link_to_args)
    content_for :navbaritems do
      content_tag(:li, link_to_unless_current(*link_to_args)) + "\n"
    end
  end
  
  def opensearch_headers(collection = nil)
    msg = [tag("link",  {:href=>"/assets/opensearch.xml",
      :rel=>"search",
      :type=>"application/opensearchdescription+xml",
      :title=>"pbcore"})]
    unless collection.nil?
      opensearch_properties(collection).each do |k,v|
        msg << tag("meta", { "name" => k, "content" => v })
      end
    end
    msg.join("\n")
  end
  
  def opensearch_properties(collection)
    collection = collection.results if collection.respond_to?(:results)
    {
      "totalResults" => collection.total_entries,
      "startIndex" => collection.offset + 1,
      "itemsPerPage" => 20
    }
  end
  
  def alternate_views
    @alternates.map{|href,type| tag(:link,:href=>href, :rel=>:alternate, :type=>type)}.join
  end
end
