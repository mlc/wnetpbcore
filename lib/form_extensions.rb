class ActionView::Helpers::FormBuilder
  def custom_select(method, options = {})
    "<select name=\"#{@object_name.to_s}[#{method.to_s}]\">" +
      yield +
      "</select>"
  end
end