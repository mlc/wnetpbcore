class AssetsController < ApplicationController
  prepend_before_filter :fetch_asset
  filter_access_to :all
  filter_access_to :opensearch, :require => :read
  filter_access_to :toggleannotations, :require => :read
  filter_access_to :lastsearch, :require => :read
  filter_access_to :picklists, :require => :read
  filter_access_to :picklist, :require => :read
  filter_access_to :edit, :attribute_check => true
  filter_access_to :update, :attribute_check => true
  filter_access_to :destroy, :attribute_check => true

  def index
    params.delete("x")
    params.delete("y")
    alternate "application/atom+xml", params.merge(:format => "atom")
    the_query = params[:q]
    pageopts = {:page => params[:page] || 1, :per_page => 20}
    pageopts[:page] = 1 if pageopts[:page] == "" || pageopts[:page].to_i < 1
    asset_includes = [:titles, {:identifiers => [:identifier_source]}, {:instantiations => [:format, :format_ids, :annotations, :borrowings]}, :descriptions]
    the_params = params # so it can be seen inside the search DSL.
    streamable = session[:streamable] # ditto

    @search_object = Asset.search do
      paginate pageopts
      data_accessor_for(Asset).include = asset_includes
      if the_query
        fulltext the_query
      else
        order_by :updated_at, :desc
      end
      dynamic :facets do
        PBCore.config['facets'].map{|facet| facet[0]}.each do |facet_name|
          facet facet_name, :limit => 15
          if the_params["facet_#{facet_name}"]
            the_params["facet_#{facet_name}"].reject!{|val| val.empty?}

            the_params["facet_#{facet_name}"].each do |value|
              with facet_name, value
            end
          end
        end
      end
      if streamable
        with :online_asset, true
      end
    end
    @query = the_query
    @assets = @search_object.results

    if @assets.empty?
      flash.now[:message] = "Nothing found."
    end

    respond_to do |format|
      format.html { session[:search] = params }
      format.atom
    end
  end
  
  def destroy
    asset = Asset.find(params[:id], :include => :titles)
    titles = asset.title
    asset.destroy
    @destroyed_id = params[:id]
    
    respond_to do |format|
      format.html do
        flash[:warning] = "<strong>#{titles}</strong> has been deleted from the database."
        lastsearch
      end
      format.js
    end
  end

  # DANGEROUS!
  def destroy_found_set
    if params[:q].nil? || params[:q].strip.blank?
      flash[:error] = "No search query provided."
      redirect_to :action => "index" and return
    end

    query = params[:q]
    asset_terms = AssetTerms.search(query, {:match_mode => :extended, :per_page => 10000, :include => { :asset => Asset::ALL_INCLUDES }})
    asset_terms.each do |at|
      at.asset.destroy
    end

    flash[:message] = "#{asset_terms.size} assets matching the query <tt>#{params[:q]}</tt> destroyed."
    session[:search] = nil
    redirect_to :action => "index"
  end
  
  def show
    alternate "application/xml", :format => "xml"
    if @asset
      respond_to do |format|
        format.html do
          if @asset.online? && permitted_to?(:watch_video, @asset)
            enable_flash
            @video = @asset.instantiations.detect(&:online?)
          end
        end
        format.xml { render :xml => @asset.to_xml }
      end
    else
      flash[:error] = "Invalid Asset ID specified"
      redirect_to :action => 'index'
    end
  end
  
  def new
    @asset = Asset.new
    @asset.titles.build
    respond_to do |format|
      format.html
      format.xml do
        if PBCore.config["auto_id"]
          identifier_source = IdentifierSource.find_or_create_by_name(PBCore.config["auto_id"])
          @asset.identifiers = [Identifier.new(:identifier_source => identifier_source, :identifier => (identifier_source.next_sequence).to_s)]
        else
          @asset.identifiers.build
        end
        render :xml => @asset.to_xml
      end
    end
  end
  
  def edit
    # just show form
  end
  
  def create
    Asset.transaction do
      @asset = Asset.from_xml(params[:xml])
      @success = @asset.save
      raise ActiveRecord::Rollback unless @success
    end

    if @success
      flash[:message] = "Successfully created new Asset. You must now add an instantiation for the record to be valid PBCore."
    end
  end
  
  def update
    @asset.transaction do
      parsed_asset = Asset.from_xml(params[:xml])
      [:identifiers, :titles, :subjects, :descriptions, :genres,
       :relations, :coverages, :audience_levels, :audience_ratings,
       :creators, :contributors, :publishers, :rights_summaries, :extensions].each do |field|
        @asset.send("#{field}=".to_sym, parsed_asset.send(field))
      end
      @success = @asset.save
      raise ActiveRecord::Rollback unless @success
    end
    if @success
      flash[:message] = "Successfully updated your Asset."
    end
  end

  # give opensearch descriptor document
  def opensearch
    respond_to do |format|
      format.xml
    end
  end

  def multiprocess
    case params[:commit]
    when /^merge/i
      merge
    when /^lend/i
      multilend
    else
      lastsearch
    end
  end

  def multilend
    @instantiations = params[:instantiation_ids] ? Instantiation.find(params[:instantiation_ids], :include => [:borrowings, {:asset => [:titles]}, :format_ids, :format]) : nil
    @instantiations = @instantiations.select{|i| !i.borrowed?}

    if @instantiations.empty?
      return lastsearch
    elsif params[:person]
      if params[:person].empty?
        flash.now[:warning] = "You must specify a person to lend to."
        render :action => 'multilend' and return
      end
      @instantiations.each do |instantiation|
        instantiation.borrowings << Borrowing.new(:person => params[:person], :department => params[:department], :borrowed => Time.new)
        instantiation.save
      end
      flash[:message] = "The items have been marked as borrowed."
      return lastsearch
    else
      render :action => 'multilend'
    end
  end

  def merge
    assets = params[:asset_ids] ? Asset.find(params[:asset_ids]) : nil
    if assets.nil? || assets.size < 2
      flash[:warning] = "You must select at least two assets to merge."
    else
      first = assets.shift
      assets.each do |asset|
        first.merge(asset)
      end
      if first.save
        assets.each do |asset|
          asset.reload
          asset.destroy
        end
        flash[:message] = "Your assets have been merged."
      else
        flash[:error] = "An error occurred merging the selected assets."
      end
    end
    redirect_to :action => "index", :q => params[:q], :page => params[:page]
  end

  # if I were better at javascript, I'd do this all (including setting a cookie)
  # without talking to the server...
  def toggleannotations
    session[:show_annotations] = !session[:show_annotations]
    @visible = session[:show_annotations]
    respond_to do |format|
      format.html { redirect_to :action => "index" }
      format.js
    end
  end

  def lastsearch
    if session[:search].is_a?(Hash)
      redirect_to session[:search]
    else
      redirect_to :action => 'index'
    end
  end

  def picklists
    classes = [Genre, Subject, ContributorRole, CreatorRole, IdentifierSource, PublisherRole, TitleType, DescriptionType, RelationType, AudienceLevel, AudienceRating]
    @picklists = {}
    classes.each do |kl|
      options = kl.quick_load_for_select(["visible = ?", true])
      @picklists[kl.to_s] = options.map(&:first)
    end
    @picklists["CoverageType"] = ["Spatial", "Temporal"]
    # FIXME: do something useful
    @valuelists = {
      "TitleType" => { "Series" => ["23 Park Avenue with Lee Graham", "9/11 Anniversary Coverage", "9/11 Commission Hearings", "AP World in Sound", "ASCAP ", "Alicia Zuckerman", "All Things Considered", "Allison Keyes", "America's Town Meeting of the Air", "American Music Festival", "American Radio Works", "Americathon", "Amy Eddings", "Andrea Bernstein", "Andrew Meyer", "Andy Lanset", "Antiquity on Tape", "Apollo", "Around New York", "Art in New York", "Arthur Miller", "Artists in the City", "Arts Alive From the Algonquin", "Arts at St. Ann's", "Arun Venugopal", "BBC", "Bach Monday", "Bargemusic", "Basically Bach", "Behind the Scenes in Music", "Beth Fertig", "Bicentennial ", "Blackout 2003", "Bob Hennelly", "Books and Authors Luncheon", "Books in Profile", "Brian Lehrer Show Clip Library", "Brian Lehrer Show", "Brian Lehrer", "CBS Library of Contemporary Quotations", "CBS at 50", "CBS", "Campaign Recordings", "Campaign Songs and Advertisements", "Campus Press Conference", "Carnegie Hall", "Central Park SummerStage", "Cindy Rodriguez", "Citizen's Searchlight", "City Classics", "City Record", "Civil Rights", "Classic Bob and Ray", "Classic Performances from the Library of Congress", "Clyfee Madhu", "Columbia Literary Series", "Comic Parade", "Composers' Forum", "Concerts from the Frick Collection", "Conductors in Conversation", "Conversation, The", "Cooper Union Forum", "D-Day", "David Feige", "David Garland", "David Randolph Rehearses", "David Randolph Singers", "Dick Cavett Show", "Dick Hinchliffe", "Dish", "Dissent", "Documentary", "Don Mathisen", "Edward T. Canby Collection", "Elaine Rivera", "Eleanor Fischer Collection", "Evening Music", "Feminism", "Film music", "Fiorello H. La Guardia", "Fishko Files", "Folk Music Almanac", "Folk and Baroque", "Folksong Festival", "For Doctors Only", "Fred Mogul", "Future Forward", "George Bush", "Gift Collection Records", "Global Podium", "Golden Door, The", "Graduate Fortnight", "Greece Under the Junta", "Greene Space", "Hands Across the Sea", "Heat", "Here's Heidy", "Historic City Hall", "History in Words", "History of the Phonograph", "Hour of Power", "Hudson Series", "Insight", "Intelligence Squared", "International Interview", "Jessie Graham", "Jo Ann Allen", "John Kalish", "John Rudolph", "John Schaefer", "Jonathan Schwartz", "Journey into Folksong, A", "Judith Kampfner", "Karen DeWitt", "Kathleen Horan", "Kerry Nolan", "Keyboard Masters", "Kids America", "Kurt Andersen", "Laura Sydell", "Lectures to the Laity", "Lend Us Your Ears", "Leonard Lopate Show", "Leonard Lopate", "Leticia Theodore", "Lewisohn Stadium Concert", "Little Orchestra Society", "Lively Arts, The", "Lower Manhattan Development Corporation", "Mad About Music", "Madeira Bach", "Marianne McCune", "Mark Hilan", "Masterwork Hour", "Masur on Music", "Meet the Composer", "Meet the Press", "Memoirs of the Movies", "Men of Hi-Fi", "MET", "Metropolitan Report", "Michael Bloomberg", "Mind Over Music", "Miscellaneous", "Mississippi Summer", "Morning Edition", "Mostly Mozart", "Music by New Americans", "Music Magazine", "Music for the Connoisseur", "Music from the Movies", "Musica Sacra", "Musical Chronicle", "Musical Playbill", "NBC", "National Press Club", "New Horizons in Science", "New Old and Unexpected", "New Sounds Live", "New Sounds", "New York & Company", "New York Beat", "New York Cabaret Nights", "New York Considered", "New York Is a Summer Festival", "New York Kids", "New York Philharmonic", "New York Talkers", "New York Tomorrow", "New York Voices", "New York World's Fair", "News Clips", "News Parade, The", "News", "Newsweek", "Next Big Thing, The", "Night with The New Yorker, A", "Nightmare Country- The Theater of Gothic Terror", "Nixon Materials Project", "No Show, The", "Northwestern University Reviewing Stand", "Now Hear This", "Ojai Music Festival", "Old Time Radio Shows", "On the Line", "On the Media", "Opera Topics with Lorenzo Alvary", "Oscar Brand", "Other People's Business", "Overnight Music", "Overseas Press Club", "Owen Gleiberman", "Panorama of the Lively Arts", "Patricia Marx", "Patricia Willens", "Paul Robeson", "Pearl Harbor", "People and Ideas", "Perspective", "Peter W. Rodino Oral History", "Peter W. Rodino", "Plan for Survival", "Playback", "Playing Favorites", "Poet in Residence", "Poet's Voice", "Police Safety Program", "RFK 1967", "Radio Reader, The", "Radio Rookies", "Radio Stage, The", "Radio X", "Radiolab", "Reader's Almanac", "Recollections at 30", "Recordings, Etc.", "Records of the Office of the Secretary of the Interior", "Report to Consumers", "Report to the Chairman", "Reporter on the Afterlife", "Richard Hake", "Riots", "Rodino Talks to the People", "Round and About the Guggenheim", "Rudolph W. Giuliani", "Salute to the Arts", "Sarah Montague", "Satellite Sisters", "Selected Shorts", "Seminars in Theatre", "Senior Edition", "Sense of Place, A", "Singing Lady, The", "Six Months: Rebuilding Our City, Rebuilding Ourselves", "Small Things Considered", "Songs of the Presidents", "Soterios Johnson", "Sound Effects", "Soundcheck", "Sounding Board", "Speaking of Dance", "Spinning On Air", "Spoken Word, The", "Spoken Words", "State of the Union", "Stories From Many Lands", "String Classics", "Studio 360", "Summer Fling", "Sunday Papers", "Superstar Profile", "Survival Kit", "Takeaway, The", "Talk to the People", "Tanglewood", "Teenage Book Talk", "There's a New World A'Coming", "Think Globally", "This is My Music", "To the Moon", "Tony Schwartz", "Toward a Return to Society", "Transit Strike 2005", "Two on a Trip", "United Nations Radio", "United Nations", "Unity at Home, Victory Abroad", "Universal Newsreel", "Urban News Weekly", "V.D. Radio Project", "VE Day", "VJ Day", "Victory Concert", "Views and People In The News", "Views on Art", "Visitors From the Other Side", "Vocal Scene", "Voice of America", "Voice of the Theatre", "Voices at the New York Public Library", "Voices of History - Israel", "WNYC American Art Festival", "WNYC Anniversaries", "WNYC Annual Book Festival", "WNYC Forum of the Air", "WNYC History", "WNYC Live", "WNYC Moe Asch Recordings", "WNYC World Trade Center Oral History", "WQXR Anniversaries", "WQXR History", "Wall to Wall", "War in Our Time", "Warner Pathé \"News-Magazine of the Screen\" Newsreel", "Weekend Around Town", "Westinghouse Washington Feed", "Women's Lib", "Works Progress Administration", "World Trade Center Attack", "World of Dance", "Worlds of Music", "Writer's Studio, The", "Yiddish Radio Project", "Young American Artist, The", "Young Artists Showcase", "Young Musician, The", "Yuri Yuhananov Collection"] }
    }
    respond_to do |format|
      format.json do
        response.headers["Cache-Control"] = "private, max-age=600"
        render :json => {:picklists => @picklists, :valuelists => @valuelists, :extension_names => ExtensionName.all}.to_json
      end
    end
  end

  def picklist
  end

  protected
  def fetch_asset
    if params[:id] =~ /^[\d]+$/
      @asset = Asset.find(params[:id], :include => Asset::ALL_INCLUDES)
    elsif params[:id]
      @asset = Asset.find_by_uuid(params[:id].gsub(/^urn:uuid:/, ''), :include => Asset::ALL_INCLUDES)
    end
  end
end
