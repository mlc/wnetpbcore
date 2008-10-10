xml.instruct!
xml.feed :xmlns => 'http://www.w3.org/2005/Atom', "xmlns:opensearch" => "http://a9.com/-/spec/opensearch/1.1/" do |atom|
  atom.title @page_title, :type => :text
  atom.link :href => url_for(:action => 'index', :q => @query, :only_path => false), :type => 'text/html', :rel => :alternate
  atom.link :href => url_for(:action => 'index', :q => @query, :format => :atom, :only_path => false), :rel => :self, :type => 'application/atom+xml'
  atom.id url_for(:action => 'index', :q => @query, :only_path => false)
  atom.author do
    atom.name "PBCore XML Database"
  end
  atom.generator "PBCore XML Database"
  atom.updated Time.new.iso8601
  opensearch_properties(@assets).each do |property, value|
    atom.opensearch property.to_sym, value
  end
  @assets.each do |asset|
    atom.entry do
      atom.title asset.titles.map{|t| t.title}.join(", "), :type => :text
      atom.link :href => asset_url(asset), :type => 'text/html', :rel => :alternate
      atom.link :href => formatted_asset_url(asset, "xml"), :type => 'application/xml', :rel => :alternate
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