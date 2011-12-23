module InstantiationHelper
  def autocomplete_source_for_format_type(instantiation)
    case instantiation.format.class
    when FormatDigital
      format_digitals_path
    else FormatPhysical
      format_physicals_path
    end
  end
end