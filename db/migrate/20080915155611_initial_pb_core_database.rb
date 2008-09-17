class InitialPbCoreDatabase < ActiveRecord::Migration
  def self.up
    create_table "assets" do |t|
      t.timestamps
    end

    create_table "identifiers" do |t|
      t.column :asset_id, :int
      t.column :identifier, :string, :null => false
      t.column :identifier_source_id, :int
      t.timestamps
    end
    add_index :identifiers, :asset_id
    add_index :identifiers, [:identifier, :identifier_source_id]

    create_table "identifier_sources" do |t|
      t.column :name, :string, :null => false
      t.timestamps
    end

    create_table "titles" do |t|
      t.column :asset_id, :int
      t.column :title, :string, :null => false
      t.column :title_type_id, :int
      t.timestamps
    end
    add_index :titles, :asset_id
    add_index :titles, :title_type_id

    create_table "title_types" do |t|
      t.column :name, :string, :null => false
      t.column :category_id, :int
    end
    add_index :title_types, :name

    create_table "title_type_categories" do |t|
      t.column :name, :string, :null => false
    end

    {
      "Express Relationships" => ["Package", "Project", "Collection", "Series",
                                  "Episode", "Program", "Segment", "Clip",
                                  "Scene", "Shot", "Selection or Excerpt",
                                  "Alternative"],
      "Accessibility Options" => ["Caption File", "Descriptive Audio",
                                  "Transcript File"],
      "Audio Recordings" => ["Music", "Nature/ambient sound", "Song", "Voice"],
      "Imagery" => ["Art Work", "Chart", "Diagram", "Drawing", "Graphic",
                    "Map", "Model", "Photograph", "Picture", "Postcard",
                    "Poster"],
      "Interactive Experiences" => ["Courseware Class", "Courseware Module",
                                    "Drill and Practice", "Game",
                                    "Model Building", "Quiz",
                                    "Reflection Activity", "Role Play",
                                    "Self Assessment", "Simulation", "Test",
                                    "Web page/site"],
      "Presentations" => ["Linear Presentation", "Multimedia Presentation",
                          "Slide Show", "Traditional Academic Poster",
                          "Electronic Academic Poster", "Kiosk Event"],
      "Text Documents" => ["Syllabus", "Lesson Plan", "Study Guide",
                           "Teacher's Guide", "Article", "Book", "Chapter",
                           "Issue", "Lyrics", "Manuscript", "Periodical",
                           "Score"],
      "Media Production & Versioning" => ["Abridged Version", "Air Version",
                                          "Captioned Version",
                                          "Cell Phone Version",
                                          "Full Version", "iPod Version",
                                          "Packaging Version",
                                          "Pledge Version",
                                          "Published Version", "Re-Title",
                                          "Web Version", "Working Title"],
      "Other" => ["Other"]
    }.each do |k,v|
      category = TitleTypeCategory.new(:name => k)
      category.save
      v.each do |cat|
        TitleType.new(:category => category, :name => cat).save
      end
    end

    create_table "subjects" do |t|
      t.column :asset_id, :int
      t.column :subject, :string, :null => false
      t.column :subject_authority, :string
      t.timestamps
    end
    add_index :subjects, :asset_id
    add_index :subjects, :subject

    create_table "descriptions" do |t|
      t.column :asset_id, :int
      t.column :description, :string, :null => false
      t.column :description_type_id, :int
      t.timestamps
    end
    add_index :descriptions, :asset_id

    create_table "description_types" do |t|
      t.column :name, :string
    end
    add_index :description_types, :name

    [
     "Abstract", "Package", "Project", "Collection", "Series", "Episode",
     "Program", "Segment", "Clip", "Selection or Excerpt", "Table of Contents",
     "Segment Sequence", "Rundown", "Playlist", "Script", "Transcript",
     "Descriptive Audio", "PODS", "PSD", "Anecdotal Comments & Reflections",
     "Listing Services", "Content Flags", "Other"
    ].each do |desc|
      DescriptionType.new(:name => desc).save
    end

    create_table :genres do |t|
      t.integer :asset_id
      t.string :genre, :null => false
      t.string :genre_authority_used
      t.timestamps
    end
    add_index :genres, :asset_id
    add_index :genres, :genre

    create_table :relations do |t|
      t.integer :asset_id
      t.integer :relation_type_id
      t.string :relation_identifier
      t.timestamps
    end
    add_index :relations, :asset_id
    add_index :relations, :relation_identifier

    create_table :relation_types do |t|
      t.string :name, :null => false
    end

    [
     "Has Format", "Is Format Of", "Has Part", "Is Part Of", "Has Version",
     "Is Version Of", "References", "Is Referenced By", "Replaces",
     "Is Replaced By", "Requires", "Is Required By", "Other"
    ].each do |rt|
      RelationType.new(:name => rt).save
    end

    create_table :coverages do |t|
      t.integer :asset_id
      t.text :coverage, :null => false
      t.string :coverage_type, :null => false # 'spatial' or 'temporal'
      t.timestamps
    end

    create_table :audience_levels do |t|
      t.string :name, :null => false
    end

    create_table :assets_audience_levels, :id => false do |t|
      t.integer :asset_id
      t.integer :asset_level_id
    end
    add_index :assets_audience_levels, :asset_id

    [
     "K-12 (general)", "Pre-school (kindergarten)", "Primary (grades 1-6)",
     "Intermediate (grades 7-9)", "High School (grades 10-12)", "College",
     "Post Graduate", "General Education", "Educator", "Vocational", "Adult",
     "Special Audiences", "General", "Male", "Female", "Other"
    ].each do |level|
      AudienceLevel.new(:name => level).save
    end

    create_table :audience_ratings do |t|
      t.string :name, :null => false
    end

    create_table :assets_audience_ratings, :id => false do |t|
      t.integer :asset_id
      t.integer :audience_rating_id
    end
    add_index :assets_audience_ratings, :asset_id

    [
     "E", "TV-Y", "TV-Y7", "TV-Y7-FV", "TV-G", "TV-PG", "TV-PG+VSLD",
     "TV-PG+VSL", "TV-PG+VSD", "TV-PG+VS", "TV-PG+VLD", "TV-PG+VL",
     "TV-PG+VD", "TV-PG+V", "TV-PG+SLD", "TV-PG+SL", "TV-PG+SD", "TV-PG+S",
     "TV-PG+LD", "TV-PG+L", "TV-PG+D", "TV-14", "TV-14+VSLD", "TV-14+VSL",
     "TV-14+VSD", "TV-14+VS", "TV-14+VLD", "TV-14+VL", "TV-14+VD", "TV-14+V",
     "TV-14+SLD", "TV-14+SL", "TV-14+SD", "TV-14+S", "TV-14+LD", "TV-14+L",
     "TV-14+D", "TV-MA", "TV-MA+VSL", "TV-MA+VS", "TV-MA+VL", "TV-MA+V",
     "TV-MA+SL", "TV-MA+S", "TV-MA+L", "MPAA: G", "MPAA: PG", "MPAA: PG-13",
     "MPAA: R", "MPAA: NC-17", "MPAA: NR"
    ].each do |rating|
      AudienceRating.new(:name => rating).save
    end

    create_table :creators do |t|
      t.integer :asset_id
      t.string :creator, :null => false
      t.integer :creator_role_id
      t.timestamps
    end
    add_index :creators, :asset_id
    add_index :creators, :creator

    create_table :creator_roles do |t|
      t.string :name, :null => false
    end
    add_index :creator_roles, :name

    [
     "Artist", "Associate Producer", "Cinematographer", "Composer",
     "Co-Producer", "Creator", "Director", "Editor", "Essayist",
     "Executive Producer", "Host", "Illustrator", "Interviewer", "Moderator",
     "Photographer", "Producer", "Production Unit", "Reporter", "Writer",
     "Other"
    ].each do |role|
      CreatorRole.new(:name => role).save
    end

    create_table :contributors do |t|
      t.integer :asset_id
      t.string :contributor, :null => false
      t.integer :contributor_role_id
      t.timestamps
    end
    add_index :contributors, :asset_id
    add_index :contributors, :contributor

    create_table :contributor_roles do |t|
      t.string :name, :null => false
    end
    add_index :contributor_roles, :name

    [
     "Actor", "Advisor", "Anchor", "Arranger", "Artist", "Assistant Cameraman",
     "Assistant Director", "Assistant Editor", "Assistant Producer - Film",
     "Assistant Researcher", "Assistant Stage Manager",
     "Assistant to the Producer", "Assistant Unit Manager",
     "Associate Director", "Associate Producer", "Audio", "Audio Assistant",
     "Audio Editor", "Audio Engineer", "Audio Mixer", "Author",
     "Boom Operator", "Camera Assistant", "Cameraperson", "Casting",
     "Chief Camera - Segment", "Cinematographer", "Commentary Editor",
     "Commentator", "Community Coordinator", "Composer", "Concept",
     "Conductor", "Contributor", "Co-Producer", "Crane", "Director",
     "Director - Artistic", "Director - Dance", "Director - Doc Material",
     "Director - Segment", "Edit Programmer", "Editor", "Editor - graphics",
     "Editor - Segment", "Engineer", "Essayist", "Executive Producer",
     "Fashion Consultant", "Film Editor", "Film Sound", "Filmmaker",
     "Floor Manager", "Funder", "Gaffer", "Graphic Designer", "Graphics",
     "Guest", "Host", "Illustrator", "Instrumentalist", "Intern",
     "Interpreter", "Interviewee", "Interviewer", "Lecturer", "Lighting",
     "Lighting Assistant", "Lighting Director", "Make-Up",
     "Mobile Unit Supervisor", "Moderator", "Music Assistant",
     "Music Coordinator", "Music Director", "Musical Staging", "Musician",
     "Narrator", "News Director", "Panelist", "Performer", "Performing Group",
     "Photographer", "Post-prod Audio", "Post-prod Supervisor", "Producer",
     "Producer - Segment", "Production Assistant", "Production Manager",
     "Production Personnel", "Production Personnel", "Production Secretary",
     "Production Unit", "Project Director", "Publicist", "Reader",
     "Recording engineer", "Recordist", "Reporter", "Researcher",
     "Scenic Design", "Senior Editor", "Senior Researcher", "Sound",
     "Sound Mixer", "Speaker", "Staff Volunteer", "Stage Manager",
     "Still Photography", "Studio Technician", "Subject", "Switcher",
     "Synthesis", "Synthesis Musician", "Talent Coordinator",
     "Technical Consultant", "Technical Director", "Technical Production",
     "Theme Music", "Titlist", "Translator", "Unit Manager", "Video",
     "Videotape Assembly", "Videotape Editor", "Videotape Engineer",
     "Videotape Recordist", "Vidifont Operator", "Vocalist", "VTR Recordist",
     "Wardrobe", "Writer", "Other"
    ].each do |role|
      ContributorRole.new(:name => role).save
    end

    create_table :publishers do |t|
      t.integer :asset_id
      t.string :publisher, :null => false
      t.integer :publisher_role_id
      t.timestamps
    end
    add_index :publishers, :asset_id

    create_table :publisher_roles do |t|
      t.string :name, :null => false
    end
    add_index :publisher_roles, :name

    [
     "Copyright Holder", "Distributor", "Presenter", "Publisher",
     "Release Agent", "Other"
    ].each do |pub|
      PublisherRole.new(:name => pub).save
    end

    create_table :rights_summaries do |t|
      t.integer :asset_id
      t.text :rights_summary, :null => false
      t.timestamps
    end
    add_index :rights_summaries, :asset_id

    create_table :instantiations do |t|
      t.integer :asset_id
      t.string :date_created
      t.string :date_issued
      t.integer :format_id
      t.string :format_location, :null => false
      t.integer :format_media_type
      t.integer :format_generation_id
      t.string :format_file_size
      t.string :format_time_start
      t.string :format_duration
      t.string :format_data_rate
      t.integer :format_color_id
      t.text :format_tracks
      t.text :format_channel_configuration
      t.string :language
      t.text :alternative_modes
      t.timestamps
    end
    add_index :instantiations, :asset_id

    create_table :format_ids do |t|
      t.integer :instantiation_id
      t.string :format_identifier, :null => false
      t.string :format_identifier_source
      t.timestamps
    end
    add_index :format_ids, :instantiation_id

    create_table :formats do |t|
      t.string :type, :null => false # STI
      t.string :name, :null => false
    end
    add_index :formats, [:type, :name]

    [
     "Film: 8mm", "Film: 16mm", "Film: 35mm", "Film: 70mm", "8mm video",
     "8mm: Hi8 Video", "8mm: Digital-8", "1/4 inch videotape: Akai",
     "1/2 inch videotape: CV", "1/2 inch videotape: EIAJ Type 1",
     "1/2 inch videotape: VCR", "1/2 inch videotape: V2000",
     "1/2 inch videotape:Hawkeye/Recam/M", "3/4 inch videotape: U-matic",
     "3/4 inch videotape: U-matic SP", "1 inch videotape: PI-3V",
     "1 inch videotape: EV-200", "1 inch videotape: EL3400",
     "1 inch videotape: SMPTE Type A", "1 inch videotape: SMPTE Type B",
     "1 inch videotape: SMPTE Type C", "1 inch videotape: IVC-700/800/900",
     "1 inch videotape: Helical BVH-1000", "2 inch videotape: Quad",
     "2 inch videotape: Helical Ampex VR-1500",
     "2 inch videotape: Sony Helical SV-201",
     "2 inch videotape: Helical IVC-9000", "Betacam", "Betacam SP",
     "Betacam Digital (Digi Beta)", "Betacam SX", "Betamax/Super/HB",
     "DV Mini", "DVC-Pro 25", "DVC-Pro 50", "DVC-Pro 50/P", "DVCam: Sony",
     "D1", "D2", "D3", "D5", "D6", "D7", "HD: D5", "HD: D9", "HD: DVC PRO HD",
     "HDCAM", "VHS", "S-VHS", "W-VHS", "CD-Video", "CD-ROM", "DVD-Video",
     "HD-Videodisc", "BD-Videodisc", "UMD-Videodisc: Sony",
     "EVD-Videodisc: China", "DVD-R", "DVD+R", "DVD-RW", "DVD+RW", "DVD+R DL",
     "Laser Videodisc CAV: 12-inch", "Laser Videodisc CLV: 12-inch",
     "Hard Drive", "Flash Memory", "Cartivision", "CVC", "DCT", "ED-Beta",
     "EIAJ Cartridge", "HDD1000", "HDV1000", "Macthronics MVC-10", "M-II",
     "MPEG IMX", "UniHi", "V-Cord", "V-Cord II", "VTR150", "VTR600", "VX",
     "1/4 inch audio tape", "1/2 inch audio tape", "1/2 inch digital audio",
     "1 inch audio tape", "2 inch audio tape", "Audio cart", "CD-Audio",
     "DVD-Audio", "DARS: DA-88", "DAT", "LP Record", "LP Record (45)",
     "Hard Drive", "Flash Memory", "1/4 inch audio cassette",
     "1/8 inch audio cassette", "8-Track cassette", "Lacquer discs/acetates",
     "Shellac discs", "F1 Beta tape", "DBX 700 VHS tape", "Wire",
     "High 8 - DA78", "Roland DM 80", "Minidisc", "Art original", "Art print",
     "Art reproduction", "Chart", "Filmstrip", "Flash card", "Flip chart",
     "Kodak PhotoCD", "Photograph", "Picture", "Postcard", "Poster",
     "Radiograph", "Slide", "Stereograph", "Study print", "Technical drawing",
     "Transparency", "Wall chart", "Binder", "Book", "Manuscript", "Newspaper",
     "Paper", "Periodical"
    ].each do |pfmt|
      FormatPhysical.new(:name => pfmt).save
    end

    [
     "not specified", "video/3gpp", "video/3gpp2", "video/3gpp-tt",
     "video/BMPEG", "video/BT656", "video/CelB", "video/DV",
     "video/H261", "video/H263", "video/H263-1998", "video/H263-2000",
     "video/H264", "video/JPEG", "video/MJ2", "video/MP1S",
     "video/MP2P", "video/MP2T", "video/mp4", "video/MP4V-ES",
     "video/MPV", "video/mpeg", "video/mpeg4-generic", "video/nv",
     "video/parityfec", "video/pointer", "video/quicktime",
     "video/raw", "video/rtx", "video/SMPTE292M", "video/vc1",
     "video/vnd.dlna.mpeg-tts", "video/vnd.fvt",
     "video/vnd.hns.video", "video/vnd.motorola.video",
     "video/vnd.motorola.videop", "video/vnd.mpegurl",
     "video/vnd.nokia.interleaved-multimedia",
     "video/vnd.nokia.videovoip", "video/vnd.objectvideo",
     "video/vnd.sealed.mpeg1", "video/vnd.sealed.mpeg4",
     "video/vnd.sealed.swf", "video/vnd.sealedmedia.softseal.mov",
     "video/vnd.vivo", "audio/32kadpcm", "audio/3gpp", "audio/3gpp2",
     "audio/ac3", "audio/AMR", "audio/AMR-WB", "audio/amr-wb+",
     "audio/asc", "audio/basic", "audio/BV16", "audio/BV32",
     "audio/clearmode", "audio/CN", "audio/DAT12", "audio/dls",
     "audio/dsr-es201108", "audio/dsr-es202050", "audio/dsr-es202211",
     "audio/dsr-es202212", "audio/eac3", "audio/DVI4", "audio/EVRC",
     "audio/EVRC0", "audio/EVRC1", "audio/EVRCB", "audio/EVRCB0",
     "audio/EVRCB1", "audio/EVRC-QCP", "audio/G722", "audio/G7221",
     "audio/G723", "audio/G726-16", "audio/G726-24", "audio/G726-32",
     "audio/G726-40", "audio/G728", "audio/G729", "audio/G7291",
     "audio/G729D", "audio/G729E", "audio/GSM", "audio/GSM-EFR",
     "audio/iLBC", "audio/L8", "audio/L16", "audio/L20", "audio/L24",
     "audio/LPC", "audio/mobile-xmf", "audio/MPA", "audio/mp4",
     "audio/MP4A-LATM", "audio/mpa-robust", "audio/mpeg",
     "audio/mpeg4-generic", "audio/parityfec", "audio/PCMA",
     "audio/PCMU", "audio/prs.sid", "audio/QCELP", "audio/RED",
     "audio/rtp-midi", "audio/rtx", "audio/SMV", "audio/SMV0",
     "audio/SMV-QCP", "audio/t140c", "audio/t38",
     "audio/telephone-event", "audio/tone", "audio/VDVI",
     "audio/VMR-WB", "audio/vnd.3gpp.iufp", "audio/vnd.4SB",
     "audio/vnd.audiokoz", "audio/vnd.CELP", "audio/vnd.cisco.nse",
     "audio/vnd.cmles.radio-events", "audio/vnd.cns.anp1",
     "audio/vnd.cns.inf1", "audio/vnd.digital-winds",
     "audio/vnd.dlna.adts", "audio/vnd.everad.plj",
     "audio/vnd.hns.audio", "audio/vnd.lucent.voice",
     "audio/vnd.nokia.mobile-xmf", "audio/vnd.nortel.vbk",
     "audio/vnd.nuera.ecelp4800", "audio/vnd.nuera.ecelp7470",
     "audio/vnd.nuera.ecelp9600", "audio/vnd.octel.sbc",
     "audio/vnd.rhetorex.32kadpcm",
     "audio/vnd.sealedmedia.softseal.mpeg", "audio/vnd.vmx.cvsd",
     "image/cgm", "image/fits", "image/g3fax", "image/gif",
     "image/ief", "image/jp2", "image/jpeg", "image/jpm", "image/jpx",
     "image/naplps", "image/png", "image/prs.btif", "image/prs.pti",
     "image/t38", "image/tiff", "image/tiff-fx",
     "image/vnd.adobe.photoshop", "image/vnd.cns.inf2",
     "image/vnd.djvu", "image/vnd.dwg", "image/vnd.dxf",
     "image/vnd.fastbidsheet", "image/vnd.fpx", "image/vnd.fst",
     "image/vnd.fujixerox.edmics-mmr",
     "image/vnd.fujixerox.edmics-rlc", "image/vnd.globalgraphics.pgb",
     "image/vnd.microsoft.icon", "image/vnd.mix", "image/vnd.ms-modi",
     "image/vnd.net-fpx", "image/vnd.sealed.png",
     "image/vnd.sealedmedia.softseal.gif",
     "image/vnd.sealedmedia.softseal.jpg", "image/vnd.svf",
     "image/vnd.wap.wbmp", "image/vnd.xiff", "text/calendar",
     "text/css", "text/csv", "text/directory", "text/dns",
     "text/ecmascript (obsolete)", "text/enriched", "text/html",
     "text/javascript (obsolete)", "text/parityfec", "text/plain",
     "text/prs.fallenstein.rst", "text/prs.lines.tag", "text/RED",
     "text/rfc822-headers", "text/richtext", "text/rtf", "text/rtx",
     "text/sgml", "text/t140", "text/tab-separated-values",
     "text/troff", "text/uri-list", "text/vnd.abc", "text/vnd.curl",
     "text/vnd.DMClientScript", "text/vnd.esmertec.theme-descriptor",
     "text/vnd.fly", "text/vnd.fmi.flexstor", "text/vnd.in3d.3dml",
     "text/vnd.in3d.spot", "text/vnd.IPTC.NewsML",
     "text/vnd.IPTC.NITF", "text/vnd.latex-z",
     "text/vnd.motorola.reflex", "text/vnd.ms-mediapackage",
     "text/vnd.net2phone.commcenter.command",
     "text/vnd.sun.j2me.app-descriptor",
     "text/vnd.trolltech.linguist", "text/vnd.wap.si",
     "text/vnd.wap.sl", "text/vnd.wap.wml", "text/vnd.wap.wmlscript",
     "text/xml", "text/xml-external-parsed-entity",
     "application/http", "application/hyperstudio",
     "application/javascript", "application/mac-binhex40",
     "application/marc", "application/mbox",
     "application/mediaservercontrol+xml", "application/mp4",
     "application/mpeg4-generic", "application/mpeg4-iod",
     "application/mpeg4-iod-xmt", "application/msword",
     "application/mxf", "application/pdf", "application/postscript",
     "application/rdf+xml", "application/rtf", "application/rtx",
     "application/sgml", "application/sgml-open-catalog",
     "application/smil (OBSOLETE)", "application/smil+xml",
     "application/soap+fastinfoset", "application/soap+xml",
     "application/ssml+xml", "application/vnd.adobe.xfdf",
     "application/vnd.apple.installer+xml",
     "application/vnd.framemaker",
     "application/vnd.google-earth.kml+xml",
     "application/vnd.google-earth.kmz",
     "application/vnd.HandHeld-Entertainment+xml",
     "application/vnd.lotus-1-2-3", "application/vnd.lotus-approach",
     "application/vnd.lotus-freelance", "application/vnd.lotus-notes",
     "application/vnd.lotus-organizer",
     "application/vnd.lotus-screencam",
     "application/vnd.lotus-wordpro",
     "application/vnd.mozilla.xul+xml", "application/vnd.ms-artgalry",
     "application/vnd.ms-asf", "application/vnd.ms-cab-compressed",
     "application/vnd.mseq", "application/vnd.ms-excel",
     "application/vnd.ms-fontobject", "application/vnd.ms-htmlhelp",
     "application/vnd.msign", "application/vnd.ms-ims",
     "application/vnd.ms-lrm", "application/vnd.ms-powerpoint",
     "application/vnd.ms-project", "application/vnd.ms-tnef",
     "application/vnd.ms-wmdrm.lic-chlg-req",
     "application/vnd.ms-wmdrm.lic-resp",
     "application/vnd.ms-wmdrm.meter-chlg-req",
     "application/vnd.ms-wmdrm.meter-resp",
     "application/vnd.ms-works", "application/vnd.ms-wpl",
     "application/vnd.ms-xpsdocument", "application/vnd.palm",
     "application/vnd.paos.xml", "application/vnd.Quark.QuarkXPress",
     "application/vnd.visio", "application/vnd.wordperfect",
     "application/wordperfect5.1", "application/xhtml+xml",
     "application/xml", "application/xml-dtd",
     "application/xml-external-parsed-entity", "application/zip"
    ].each do |dfmt|
      FormatDigital.new(:name => dfmt).save
    end

    create_table :format_media_types do |t|
      t.string :name, :null => false
    end
    add_index :format_media_types, :name

    [
     "Animation", "Artifact", "Collection", "Dataset", "Event",
     "Interactive Resource", "Moving Image", "Physical Object", "Presentation",
     "Service", "Software", "Sound", "Static Image", "Text"
    ].each do |mt|
      FormatMediaType.new(:name => mt).save
    end

    create_table :format_generations do |t|
      t.string :name, :null => false
    end
    add_index :format_generations, :name

    [
     "Artifact/Award", "Artifact/Book", "Artifact/Costume",
     "Artifact/Merchandise", "Artifact/Optical disk reader",
     "Artifact/SCSI Hard Drive", "Artifact/Sy-Quest drive", "Audio/Air track",
     "Audio/Audio dub", "Audio/Audio master (full mix)", "Audio/Master mix",
     "Audio/Mix element", "Audio/Music", "Audio/Narration",
     "Audio/Optical track", "Audio/Original recording",
     "Audio/Radio program (Dub)", "Audio/Radio program (Master)",
     "Audio/Sound effects", "Audio/Transcription dub",
     "Container/Backup (computer files)", "Container/Sy-Quest Install Disks",
     "Moving image/Air print", "Moving image/Answer print",
     "Moving image/Backup master", "Moving image/Backup master",
     "Moving image/BW internegative", "Moving image/BW kinescope negative",
     "Moving image/BW workprint", "Moving image/Clip reel",
     "Moving image/Color edited workprint",
     "Moving image/Color internegative (CRI)", "Moving image/Color master",
     "Moving image/Color workprint", "Moving image/Distribution dub",
     "Moving image/Doc only dub", "Moving image/Doc only master",
     "Moving image/Graphics - animation", "Moving image/Green Label Master",
     "Moving image/Incomplete master", "Moving image/International master",
     "Moving image/Interpositive", "Moving image/ISO reel",
     "Moving image/Line reel", "Moving image/Master",
     "Moving image/Mixed magnetic track", "Moving image/News tape",
     "Moving image/Open - Close", "Moving image/Orig BW a & b negative",
     "Moving image/Orig BW negative", "Moving image/Orig color a & b negative",
     "Moving image/Orig color a & b reversal",
     "Moving image/Orig color negative", "Moving image/Original",
     "Moving image/Original footage", "Moving image/PBS backup",
     "Moving image/PBS dub", "Moving image/PBS master",
     "Moving image/Preservation master", "Moving image/Promo",
     "Moving image/Protection master", "Moving image/Release print",
     "Moving image/Screening tapee", "Moving image/Stock footage",
     "Moving image/Submaster", "Moving image/Sync pix and sound",
     "Moving image/Tease", "Moving image/Viewing copy",
     "Moving image/Work print", "Static image/Autochrome",
     "Static image/Caricature", "Static image/Carte de viste",
     "Static image/Color print", "Static image/Contact sheet",
     "Static image/Daguerrotype", "Static image/Digital file",
     "Static image/Drawing", "Static image/Engraving",
     "Static image/Glass negative", "Static image/Glass slide",
     "Static image/Illustration", "Static image/Lithograph",
     "Static image/Map", "Static image/Nitrate negative",
     "Static image/Other (see note)", "Static image/Painting",
     "Static image/Photo research file", "Static image/Photocopy",
     "Static image/Photograph", "Static image/Postcard", "Static image/Print",
     "Static image/Slide", "Static image/Stereoview", "Static image/Still",
     "Static image/Transparency", "Static image/Woodcut",
     "Text/Accounting statements", "Text/Budget file", "Text/Caption file",
     "Text/Contracts", "Text/Correspondence", "Text/Credit list",
     "Text/Crew list", "Text/Cue sheet", "Text/Documentation", "Text/EDL",
     "Text/Educational Material", "Text/Invoices - Receipts", "Text/Letter",
     "Text/Logs", "Text/Lower thirds list", "Text/Manuscript",
     "Text/Meeting notes", "Text/Newspaper article", "Text/Press clippings",
     "Text/Press kits", "Text/Press releases", "Text/Production notes",
     "Text/Promotional material", "Text/Proposals", "Text/Releases",
     "Text/Reports", "Text/Research material", "Text/Scripts",
     "Text/Transcript", "Text/Transcript - interview",
     "Text/Transcript - program"
    ].each do |fg|
      FormatGeneration.new(:name => fg).save
    end

    create_table :format_colors do |t|
      t.string :name, :null => false
    end
    [
     "B&W", "Grayscale", "Color", "B&W with grayscale sequences",
     "B&W with color sequences", "Grayscale with B&W sequences",
     "Grayscale with color sequences", "Color with B&W sequences",
     "Color with grayscale sequences", "Other"
    ].each do |fc|
      FormatColor.new(:name => fc).save
    end

    create_table :essence_tracks do |t|
      t.integer :instantiation_id
      # these are not documented yet...
      # maybe some should eventually be lookup tables...
      t.string :essence_track_identifier
      t.string :essence_track_identifier_source
      t.string :essence_track_standard
      t.string :essence_track_encoding
      t.string :essence_track_data_rate
      t.string :essence_track_time_start
      t.string :essence_track_duration
      t.string :essence_track_bit_depth
      t.string :essence_track_sampling_rate
      t.string :essence_track_frame_size
      t.string :essence_track_aspect_ratio
      t.string :essence_track_frame_rate
      t.string :essence_track_language
      t.text :essence_track_annotation
    end
    add_index :essence_tracks, :instantiation_id

    create_table :date_availables do |t|
      t.integer :instantiation_id
      t.string :date_available_start
      t.string :date_available_end
    end
    add_index :date_availables, :instantiation_id

    create_table :annotation do |t|
      t.integer :instantiation_id
      t.text :annotation
    end
    add_index :annotation, :instantiation_id

    create_table :extensions do |t|
      t.integer :asset_id
      t.text :extension
      t.text :extension_authority_used
    end
    add_index :extensions, :asset_id
  end

  def self.down
    [ :assets, :description_types, :descriptions, :identifier_sources,
      :identifiers, :schema_migrations, :subjects, :title_type_categories,
      :title_types, :titles
    ].each do |t|
      drop_table t
    end
  end
end
