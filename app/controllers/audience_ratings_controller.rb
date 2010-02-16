class AudienceRatingsController < PicklistsController
  def set_standard_pbcore
    @standard_pbcore =
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
      ].to_set.freeze
  end
end
