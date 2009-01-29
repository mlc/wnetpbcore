class OldGenre < ActiveRecord::Base
  belongs_to :asset
end

class OldSubject < ActiveRecord::Base
  belongs_to :asset
end

class RethinkGenres < ActiveRecord::Migration
  def self.up
    rename_table :genres, :old_genres
    rename_table :subjects, :old_subjects

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

    create_table :subjects do |t|
      t.text :subject, :null => false
      t.text :subject_authority
      t.boolean :visible, :null => false, :default => false
      t.timestamps
    end

    create_table :assets_subjects, {:id => false} do |t|
      t.integer :asset_id, :null => false
      t.integer :subject_id, :null => false
    end
    add_index :assets_subjects, :asset_id

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

    [
      "Abortion", "Acid Rain", "ACLU", "Addis Ababa", "Adolescence",
      "Adoption", "Advertising", "Affirmative Action", "Afghanistan",
      "Africa", "African Americans", "Ageism", "Aging", "Agriculture",
      "AIDS", "Air Force", "Alabama", "Alaska", "Albania", "Alcohol",
      "Algeria", "Alphabet", "Alzheimer's Disease", "American History",
      "Amman", "Amsterdam", "Anatomy", "Ancient History", "Angola", "Animal Rights",
      "Animals", "Animation", "Ankara", "Antarctica",
      "Anthropology", "Antiques", "Antiquity", "Apartheid", "Archaeology",
      "Architecture", "Argentina", "Arizona", "Arkansas", "Armenia", "Arms",
      "Arms Control", "Army", "Arson", "Arthritis", "Arts", "Asbestos",
      "Asia", "Asian Americans", "Assassination Attempts", "Astronomy",
      "AT&T", "Athens", "Atlanta", "Australia", "Austria", "Automobiles",
      "Avant Garde", "Aviation", "Bahamas", "Ballet", "Baltic Republics",
      "Baltimore", "Bangkok", "Bangladesh", "Banking Industry", "Barbados",
      "Baroque", "Beirut", "Belfast", "Belgium", "Belgrade", "Belize",
      "Berlin", "Bilingualism", "Biology", "Blacks", "Bogota", "Bolivia",
      "Bombay", "Bonn", "Bosnia", "Boston", "Botany", "Botswana", "Brazil",
      "Brunei", "Brussels", "Bucharest", "Budapest", "Buddhism", "Budget",
      "Buenos Aires", "Bulgaria", "Burma", "Burundi", "Bush Administration",
      "Business", "Busing", "Cairo", "Calcutta", "California", "Cambodia",
      "Cameroon", "Campaign Finance", "Canada", "Cancer", "Canton", "Cape Town",
      "Capital Punishment", "Caracas", "Careers", "Carter Administration",
      "Catholicism", "Censorship", "Census", "Central America", "Chamber Music",
      "Charities", "Chechnya", "Chemical Dependency", "Chemical Warfare",
      "Chemistry", "Chicago", "Child Abuse", "Child Care", "Child Development",
      "Childbirth", "Children",
      "Chile", "China", "Christianity", "Christmas", "CIA", "Civil Rights",
      "Civil War", "Classical Music", "Cleveland", "Clinton Administration",
      "Cold War", "Colleges", "Colleges/Universities", "Colombia",
      "Colorado", "Communications", "Communism", "Computers", "Congo",
      "Congress", "Connecticut", "Conservation", "Conservatism",
      "Constitution", "Construction", "Consumerism", "Contraception",
      "Contras", "Cooking", "Copenhagen", "Cost Of Living", "Costa Rica",
      "Country/Western/Bluegrass", "Courts", "Crafts", "Crime", "Croatia",
      "Cuba", "Cults", "Cyprus", "Czech Republic", "Czechoslovakia",
      "Dagestan", "Dallas", "Damascus", "Dance", "Day Care", "Death",
      "Defense", "Delaware", "Delhi", "Democratic Party", "Demonstrations",
      "Denmark", "Deregulation", "Desegregation", "Detroit", "Developing Countries",
      "Diabetes", "Dinosaurs", "Diplomacy", "Disabled",
      "Discrimination", "Disease", "District Of Columbia", "Divestiture",
      "Divorce", "Dominican Republic", "Drama", "Dramatic Comedy", "Drugs",
      "Dublin", "Earthquakes", "East Germany", "Eastern Europe", "Eating Disorders",
      "Ecology", "Economics", "Economy", "Ecuador", "Education",
      "Egypt", "Eighteenth Century", "Eisenhower Administration", "El Salvador",
      "Elderly", "Elections", "Emotions", "Employment",
      "Endangered Species", "Energy", "England", "Entrepreneurship",
      "Environment", "EPA", "Epilepsy", "Eskimos", "Espionage", "Estonia",
      "Ethics", "Ethiopia", "Ethnicity", "Europe", "Euthanasia",
      "Evolution", "FAA", "Family Issues", "Farming", "Fashion", "FBI",
      "FCC", "FDA", "FDR Administration", "Federal Government",
      "Federal Reserve Board", "Feminism", "Fiber Arts", "Fiction",
      "Fifteenth Century", "Film Industry", "Finland", "Florida", "Folk Art",
      "Folk Music", "Folk/Square Dance", "Food", "Ford Administration",
      "Foreign Policy", "Forests", "France", "Fundamentalism", "Funerals", "Future",
      "Gabon", "Gambia", "Gambling", "Games", "Gangs", "Gardens",
      "Genetics", "Geneva", "Geology", "Georgia", "Germany", "Ghana",
      "Gifted", "Gold", "Gorbachev Administration", "Gospel Music",
      "Government", "Graphic Arts/Printmaking", "Great Britain", "Great Depression",
      "Great Lakes", "Greece", "Greenhouse Effect", "Grenada",
      "Guam", "Guatemala", "Guinea", "Gulf Of Mexico", "Gulf War", "Gun Control",
      "Guyana", "Haiti", "Hanoi", "Hawaii", "Health Care", "Health Cost",
      "Heart Disease", "Helsinki", "Herpes", "High Schools",
      "Highways", "Hinduism", "Hispanic Americans", "History", "Ho Chi Minh City",
      "Holidays", "Holocaust", "Home Improvement", "Homeless",
      "Homosexuality", "Honduras", "Hong Kong", "Horticulture", "Hospitals",
      "Hostages", "Housing", "Houston", "HUD", "Human Rights", "Hungary",
      "Hunger", "Hurricanes", "Iceland", "Idaho", "Illegal Aliens",
      "Illinois", "Immigration", "Impeachment", "Impressionism", "India",
      "Indiana", "Indonesia", "Industry", "Infants", "Insects", "Insurance Industry",
      "Interior Design", "Internet", "Investment", "Iowa",
      "Iran", "Iran/Contra Affair", "Iraq", "Ireland", "IRS", "Islam",
      "Israel", "Istanbul", "Italy", "Ivory Coast", "Iwo Jima", "Jakarta",
      "Jamaica", "Japan", "Jazz/Blues", "Jerusalem", "Johannesburg",
      "Johnson Administration", "Jordan", "Journalism", "Judaism",
      "Justice Department", "Juvenile Delinquents", "Kampuchea", "Kansas",
      "Kazakhstan", "Kennedy Administration", "Kentucky", "Kenya", "Korea",
      "Korean War", "Ku Klux Klan", "Kuala Lumpur", "Kurds", "Kuwait",
      "Kyrgyzstan", "Labor", "Lagos", "Language", "Laos", "Lasers", "Latin America",
      "Latvia", "Law Enforcement", "Lebanon", "Legal Issues",
      "Leningrad", "Liberalism", "Liberia", "Libya", "Lima", "Lisbon",
      "Literacy", "Literature", "Lithuania", "Lobbying", "London", "Los Angeles",
      "Louisiana", "Macedonia", "Madrid", "Maine", "Malawi",
      "Malaysia", "Mali", "Managua", "Manila", "Marines", "Marriage",
      "Marxism", "Maryland", "Massachusetts", "Mathematics", "Mauritania",
      "Mccarthyism", "Media", "Medicaid/Medicare", "Medicine", "Medieval",
      "Melbourne", "Mental Health", "Mental Retardation", "Meteorology",
      "Mexico", "Mexico City", "Miami", "Michigan", "Middle East",
      "Midwest", "Migrant Workers", "Military", "Mining", "Minneapolis",
      "Minnesota", "Minorities", "Mississippi", "Missouri", "Modern Art",
      "Modern Dance", "Monaco", "Mongolia", "Montana", "Montreal",
      "Monuments/Landmarks", "Moral Majority", "Morality", "Mormons",
      "Morocco", "Moscow", "Mozambique", "Munich", "Museums", "Music",
      "Musical Theater", "Mystery", "Myth/Mythology", "Naacp", "Nairobi",
      "Namibia", "NASA", "Nassau", "National Parks", "National Security",
      "Native Americans", "NATO", "Natural Disasters", "Nature", "Navy",
      "Nazism", "Nebraska", "Neighborhoods", "Nepal", "Netherlands",
      "Nevada", "New Age Music", "New Delhi", "New Hampshire", "New Jersey",
      "New Mexico", "New Right", "New York", "New York City", "New Zealand",
      "Newark", "Newspapers", "Nicaragua", "Niger", "Nigeria",
      "Nineteenth Century", "Nixon Administration", "Nonfiction", "North America",
      "North Carolina", "North Dakota", "North Korea", "Northern Ireland",
      "Norway", "Nuclear Issues", "Nursing", "Nursing Homes", "Nutrition",
      "Obesity", "Occult", "Oceanography", "Ohio", "Oil", "Oklahoma",
      "Olympic Games", "Oman", "One-Person Drama", "OPEC", "Opera",
      "Orchestral Music", "Oregon", "Organized Crime", "Osaka", "Oslo",
      "Pacific Islands", "Painting/Drawing", "Pakistan", "Paleontology",
      "Palestine", "Panama", "Papua New Guinea", "Paraguay", "Paris",
      "Peking", "Pennsylvania", "Persian Gulf", "Peru", "Pesticides",
      "Pets", "Philadelphia", "Philippines", "Philosophy", "Phnom Penh",
      "Photography", "Physical Fitness", "Physics", "Pittsburgh",
      "Planned Parenthood", "Playwrighting/Screenwriting", "PLO", "Poetry", "Poland",
      "Political Humor", "Politics", "Pollution", "Popular/Social Dance",
      "Population", "Pornography", "Port-Au-Prince", "Portugal",
      "Postal Service", "Pottery/Ceramics", "Poverty", "Prague", "Pregnancy",
      "Presidency", "Pretoria", "Primitive", "Prisons", "Privacy",
      "Prostitution", "Protestantism", "Psychology", "Public Policy",
      "Publishing Industry", "Puerto Rico", "Race", "Racism", "Radio",
      "Railroads", "Rape", "Reading", "Reagan Administration",
      "Recording Industry", "Refugees", "Religion", "Renaissance",
      "Reproductive Issues", "Republican Party", "Retirement", "Revolution",
      "Rhode Island", "Rio De Janeiro", "Riots", "Riyadh", "Rock/Pop Music",
      "Romania", "Romanticism", "Rome", "Royalty", "Runaways", "Russia",
      "Rwanda", "Safety Issues", "Saigon", "San Diego", "San Francisco",
      "San Salvador", "Sanitation", "Santiago", "Sao Paulo", "Sarajevo",
      "Satellites", "Saudi Arabia", "Science", "Scotland", "Sculpture",
      "Segregation", "Senegal", "Seoul", "Serbia", "Seventeenth Century",
      "Sex Education", "Sexism", "Sexual Abuse", "Sexuality", "Shanghai",
      "Ships", "Showtunes", "Sierra Leone", "Silver", "Singapore",
      "Singing", "Situation Comedy", "Sixteenth Century", "Slavery",
      "Slovakia", "Slovenia", "Social Security", "Social Services",
      "Socialism", "Sociology", "Solidarity", "Solo Recital", "Somalia",
      "South", "South Africa", "South America", "South Carolina", "South Dakota",
      "South Korea", "Southeast Asia", "Soviet Union", "Space Exploration",
      "Spain", "Special Education", "Sports", "Sri Lanka",
      "St. Louis", "Stage Production", "Stand-Up Comedy", "Stock Market",
      "Stockholm", "Storytelling", "Strikes", "Sudan", "Suicide", "Supreme Court",
      "Swaziland", "Sweden", "Switzerland", "Sydney", "Syria",
      "Taiwan", "Tajikistan", "Tanzania", "Tap/Jazz", "Taxes", "Technology",
      "Teheran", "Televangelism", "Television", "Tennessee", "Terrorism",
      "Texas", "Thailand", "Theater", "Third World", "Tibet",
      "Tobacco/Smoking", "Tokyo", "Toronto", "Toxic Waste", "Trade",
      "Transplants", "Transportation", "Trinidad", "Trinidad And Tobago",
      "Tripoli", "Trucking", "Truman Administration", "Tunis", "Tunisia",
      "Turkey", "Turkmenistan", "Twentieth Century", "Uganda", "Ukraine",
      "Unions", "United Arab Emirates", "United Nations", "Uraguay",
      "Urban Development", "Urban Issues", "Utah", "Uzbekistan", "Vatican",
      "Venereal Disease", "Venezuela", "Vermont", "Veterans", "Video/Film",
      "Vienna", "Vietnam", "Vietnam War", "Violence", "Virginia",
      "Voluntarism", "Wales", "War", "Warsaw", "Washington", "Waste Management",
      "Watergate", "Waters", "Weaponry", "Weight Control",
      "Welfare", "West", "West Germany", "West Virginia", "White Collar Crime",
      "Wildlife", "Wisconsin", "Women", "World War I", "World War II",
      "Writing/Composition", "Wyoming", "Youth", "Yugoslavia", "Zaire",
      "Zambia", "Zimbabwe", "Zoology"
    ].each do |pods|
      Subject.create(:subject => pods, :subject_authority => "PBS PODS", :visible => true)
    end

    modassets = {}
    OldGenre.find(:all).each do |oldgenre|
      aid = oldgenre.asset_id
      modassets[aid] ||= Asset.find(aid)
      modassets[aid].genres << Genre.find_or_create_by_name_and_genre_authority_used(oldgenre.genre, oldgenre.genre_authority_used)
    end

    OldSubject.find(:all).each do |oldsubject|
      aid = oldsubject.asset_id
      modassets[aid] ||= Asset.find(aid)
      modassets[aid].subjects << Subject.find_or_create_by_subject_and_subject_authority(oldsubject.subject, oldsubject.subject_authority)
    end

    modassets.each_value{|a| a.save}

    drop_table :old_genres
    drop_table :old_subjects
  end

  def self.down
    create_table :old_genres do |t|
      t.integer :asset_id
      t.text :genre, :null => false
      t.text :genre_authority_used
      t.timestamps
    end
    add_index :old_genres, :asset_id

    create_table :old_subjects do |t|
      t.integer :asset_id
      t.text :subject
      t.text :subject_authority
      t.timestamps
    end
    add_index :subjects, :asset_id

    Asset.all(:include => :genres).each do |asset|
      asset.genres.each do |genre|
        OldGenre.create(:asset_id => asset.id, :genre => genre.name, :genre_authority_used => genre.genre_authority_used)
      end

      asset.subjects.each do |subject|
        OldSubject.create(:asset => asset, :subject => subject.subject, :subject_authority => subject.subject_authority)
      end
    end

    drop_table :genres
    drop_table :assets_genres
    drop_table :subjects
    drop_table :assets_subjects

    rename_table :old_genres, :genres
    rename_table :old_subjects, :subjects
  end
end
