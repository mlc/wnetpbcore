class OldGenre < ActiveRecord::Base
  belongs_to :asset
end

class RethinkGenres < ActiveRecord::Migration
  def self.up
    rename_table :genres, :old_genres

    create_table :genres do |t|
      t.text :name, :null => false
      t.text :genre_authority_used
      t.boolean :visible, :null => false, :default => false
      t.timestamps
    end

    create_table :assets_genres, :id => false do |t|
      t.integer :asset_id, :null => false
      t.integer :genre_id, :null => false
    end
    add_index :assets_genres, :asset_id

    [
      "Action", "Actuality", "Adults Only", "Adventure", "Advice",
      "Agriculture", "Animals", "Animation", "Anime", "Anthology", "Art",
      "Arts/crafts", "Auction", "Auto", "Aviation", "Awards", "Bicycle",
      "Biography", "Boat", "Business/Financial", "Call-in", "Children",
      "Children-music", "Children-special", "Children-talk", "Collectibles",
      "Comedy", "Comedy-drama", "Commentary", "Community", "Computers",
      "Concert", "Consumer", "Cooking", "Crime", "Crime drama", "Dance",
      "Debate", "Docudrama", "Documentary", "Drama", "Educational",
      "Entertainment", "Environment", "Event", "Excerpts", "Exercise",
      "Fantasy", "Fashion", "Feature", "Forecast", "French", "Fundraiser",
      "Game show", "Gay/lesbian", "Health", "Historical drama", "History",
      "Holiday", "Holiday music", "Holiday music special", "Holiday special",
      "Holiday-children", "Holiday-children special", "Home improvement",
      "Horror", "Horse", "House/garden", "How-to",
      "Interview", "Law", "Magazine", "Medical", "Miniseries", "Music",
      "Music special", "Music talk", "Musical", "Musical comedy", "Mystery",
      "Nature", "News", "News conference", "Newsmagazine", "Obituary",
      "Opera", "Outtakes", "Panel", "Parade", "Paranormal", "Parenting",
      "Performance", "Performing arts", "Political commercial", "Politics",
      "Polls and Surveys", "Press Release", "Promotional announcement",
      "Public service announcement", "Question and Answer Session", "Quote",
      "Reading", "Reality", "Religious", "Retrospective", "Romance",
      "Romance-comedy", "Science", "Science fiction", "Self improvement",
      "Shopping", "Sitcom", "Soap", "Soap special", "Soap talk", "Spanish",
      "Special", "Speech", "Sports", "Standup", "Suspense", "Talk",
      "Theater", "Trailer", "Travel", "Variety", "Voice-over", "War",
      "Weather", "Western"
    ].each do |pbcore|
      Genre.create(:name => pbcore, :genre_authority_used => "PBCore Genre Picklist", :visible => true)
    end

    [
      "Actuality", "Adaptation", "Adventure", "Adventure (Nonfiction)",
      "Ancient world", "Animal", "Art", "Aviation", "Biographical",
      "Biographical (Nonfiction)", "Buddy", "Caper", "Chase", "Children's",
      "College", "Comedy", "Crime", "Dance", "Dark comedy", "Disability",
      "Disaster", "Documentary", "Domestic comedy", "Educational", "Erotic",
      "Espionage", "Ethnic", "Ethnic (Nonfiction)", "Ethnographic",
      "Experimental", "Absolute", "Abstract live action", "Activist",
      "Autobiographical", "City symphony", "Cubist", "Dada", "Diary",
      "Feminist", "Gay/lesbian", "Intermittent animation", "Landscape",
      "Loop", "Lyrical", "Participatory", "Portrait", "Reflexive", "Street",
      "Structural", "Surrealist", "Text", "Trance", "Exploitation", "Fallen woman",
      "Family", "Fantasy", "Film noir", "Game", "Gangster",
      "Historical", "Home shopping", "Horror", "Industrial",
      "Instructional", "Interview", "Journalism", "Jungle", "Juvenile delinquency",
      "Lecture", "Legal", "Magazine", "Martial arts",
      "Maternal melodrama", "Medical", "Medical (Nonfiction)", "Melodrama",
      "Military", "Music", "Music video", "Musical", "Mystery", "Nature",
      "News", "Newsreel", "Opera", "Operetta", "Parody", "Police",
      "Political", "Pornography", "Prehistoric", "Prison", "Propaganda",
      "Public access", "Public affairs", "Reality-based", "Religion",
      "Religious", "Road", "Romance", "Science fiction", "Screwball comedy",
      "Show business", "Singing cowboy", "Situation comedy", "Slapstick comedy",
      "Slasher", "Soap opera", "Social guidance", "Social problem",
      "Sophisticated comedy", "Speculation", "Sponsored", "Sports", "Sports (Nonfiction)",
      "Survival", "Talk", "Thriller", "Training",
      "Travelogue", "Trick", "Trigger", "Variety", "War", "War (Nonfiction)",
      "Western", "Women", "Youth", "Yukon"
    ].each do |loc|
      Genre.create(:name => loc, :genre_authority_used => "LoC Moving Image Genre List", :visible => true)
    end

    OldGenre.find(:all).each do |oldgenre|
      a = oldgenre.asset
      a.genres << Genre.find_or_create_by_name_and_genre_authority_used(oldgenre.genre, oldgenre.genre_authority_used)
      a.save
    end

    drop_table :old_genres
  end

  def self.down
    create_table :old_genres do |t|
      t.integer :asset_id
      t.text :genre, :null => false
      t.text :genre_authority_used
      t.timestamps
    end
    add_index :old_genres, :asset_id

    Asset.all(:include => :genres).each do |asset|
      asset.genres.each do |genre|
        OldGenre.create(:asset_id => asset.id, :genre => genre.name, :genre_authority_used => genre.genre_authority_used)
      end
    end

    drop_table :genres
    drop_table :assets_genres

    rename_table :old_genres, :genres
  end
end
