# -*- ruby -*-
xml.instruct!
xml.feed :xmlns => 'http://www.w3.org/2005/Atom', "xmlns:opensearch" => "http://a9.com/-/spec/opensearch/1.1/" do |atom|
  atom.title @query || 'Assets', :type => :text
  atom.link :href => url_for(:action => 'index', :q => @query, :only_path => false, :escape => false), :type => 'text/html', :rel => :alternate
  atom.link :href => url_for(:action => 'index', :q => @query, :format => :atom, :only_path => false, :escape => false), :rel => :self, :type => 'application/atom+xml'
  atom.link :href => url_for(:controller => "/pbcore.opensearch.xml", :only_path => false, :escape => false), :rel => 'search', :type => 'application/opensearch+xml'
  atom.link :href => url_for(:action => 'index', :format => :atom, :q => @query, :page => 1, :only_path => false, :escape => false), :rel => 'first', :type => 'application/atom+xml'
  atom.link :href => url_for(:action => 'index', :format => :atom, :q => @query, :page => @assets.total_pages, :only_path => false, :escape => false), :rel => 'last', :type => 'application/atom+xml'
  if @assets.next_page
    atom.link :href => url_for(:action => 'index', :format => :atom, :q => @query, :page => @assets.next_page, :only_path => false, :escape => false), :rel => 'next', :type => 'application/atom+xml'
  end
  if @assets.previous_page
    atom.link :href => url_for(:action => 'index', :format => :atom, :q => @query, :page => @assets.previous_page, :only_path => false, :escape => false), :rel => 'previous', :type => 'application/atom+xml'
  end
  atom.id url_for(:action => 'index', :q => @query, :only_path => false, :escape => false)
  atom.author do
    atom.name "PBCore XML Database"
  end
  atom.generator "PBCore XML Database"
  atom.updated Time.new.iso8601
  opensearch_properties(@search_object).each do |property, value|
    atom.opensearch property.to_sym, value
  end
  @assets.each do |asset|
    atom.entry do
      atom.title asset.title, :type => :text
      atom.link :href => asset_url(asset.uuid), :type => 'text/html', :rel => :alternate
      atom.link :href => formatted_asset_url(asset.uuid, "xml"), :type => 'application/xml', :rel => :alternate
      atom.id "urn:uuid:#{asset.uuid}"
      atom.updated asset.updated_at.iso8601
      atom.summary :type => :xhtml do
        atom.div :xmlns => "http://www.w3.org/1999/xhtml" do |html|
          asset.descriptions.each do |description|
            html.p description.description
          end
        end
      end
    end
  end
end
