module AssetsHelper
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
end
