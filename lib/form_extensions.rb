class ActionView::Helpers::FormBuilder
  def custom_select(method, options = {})
    if (options.delete(:allow_blank))
      extra = '<option value=""></option>'
    else
      extra = ''
    end
    "<select name=\"#{@object_name.to_s}[#{method.to_s}]\">" +
      extra +
      yield +
      "</select>"
  end
end