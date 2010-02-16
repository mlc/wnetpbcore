class FormatPhysicalsController < PicklistsController
  def set_standard_pbcore
    @standard_pbcore =
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
      ].to_set.freeze
  end

end
