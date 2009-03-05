module AssetsHelper
  def assets_navbar
    if @asset && !@asset.new_record?
      if permitted_to?(:show, @asset)
        add_navbar("view asset", asset_url(@asset.uuid))
        add_navbar("xml", formatted_asset_url(@asset.uuid, 'xml'))
      end
      if permitted_to?(:edit, @asset)
        add_navbar("edit asset", edit_asset_url(@asset))
      end
      if permitted_to?(:index, :instantiations)
        add_navbar("instantiations", asset_instantiations_url(@asset))
      end
    end
    if @instantiation && !@instantiation.new_record?
      if permitted_to?(:edit, @instantiation)
        add_navbar("edit instantiation", edit_asset_instantiation_url(@asset, @instantiation))
      end
      if permitted_to?(:borrowings, @instantiation)
        add_navbar("borrowings", borrowings_asset_instantiation_url(@asset, @instantiation))
      end
    end
  end

  def eltshow(fld)
    update_page do |page|
      page.visual_effect :highlight, fld, :duration => 0.5
      page.show "hide_#{fld}"
      page.hide "show_#{fld}"
    end
  end

  def elthide(fld)
    update_page do |page|
      page.hide fld
      page.hide "hide_#{fld}"
      page.show "show_#{fld}"
    end
  end

  # return all visible genres, plus possibly one selected genre, in a format
  # suitable for passing to option_groups_from_collection_for_select
  def genres_including(genre)
    genres = Genre.find(:all, :conditions => genre.nil? ? "visible = 1" : ["visible = 1 OR id = ?", genre.id], :order => "genre_authority_used ASC, name ASC")
    gentypes = {}
    genres.each do |g|
      gentypes[g.genre_authority_used] ||= []
      gentypes[g.genre_authority_used] << g
    end
    return gentypes
  end
end
