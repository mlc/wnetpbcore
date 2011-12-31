# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def title(title)
    content_for(:title) { title }
    title
  end
  
  def application_title
    PBCore.config['site_title'] || 'pbcore'
  end
  
  def add_navbar(*link_to_args)
    @have_second_nav = true
    content_for :navbaritems do
      content_tag(:li, link_to_unless_current(*link_to_args))
    end
  end
  
  def opensearch_headers(collection = nil)
    msg = [tag("link",  {:href=>"/assets/opensearch.xml",
      :rel=>"search",
      :type=>"application/opensearchdescription+xml",
      :title=> application_title})]
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

  def maybe_pluralize(n, text)
    n.to_s + " " + (n == 1 ? text : text.pluralize)
  end
  
  # Formtastic has_many form helper stuff
  def link_to_remove_fields(name, f)
    f.input(:_destroy, :as => :hidden) + 
    content_tag(:li, link_to_function(name, "remove_fields(this)", :class => "remove"), :class => "remove-wrapper")
  end
  
  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.semantic_fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, h("add_fields(this, '#{association}', '#{escape_javascript(fields)}')"))
  end
  
  def add_another(f, association, link_text = "Add another...")
    content_tag(:p, :class => "add-another") do
      link_to_add_fields(link_text, f, association)
    end
  end
  
  # Displays yes or no given a boolean
  def yes_or_no(boolean)
    boolean ? "Yes" : "No"
  end
  
  def prepopulate_language_tokens_for(object)
    object.language_tokens.split(',').collect { |token| { :id => token, :name => ISO639::ISO639_CODES[token][:en] }.to_json }
  end
end
