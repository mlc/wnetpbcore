#require 'action_view/helpers/form_tag_helper'
module FormtasticCustomizations
  class PbcoreFormBuilder < Formtastic::SemanticFormBuilder
    
    def pbcore_combobox_input(method, options)
      basic_input_helper(:text_field, :string, method, options) <<
      template.content_tag(:button, :type => :button, :class => "pbcore-combobox-button ui-button ui-widget ui-state-default ui-button-icon-only ui-corner-right ui-button-icon") do
        template.content_tag(:span, "", :class => "ui-button-icon-primary ui-icon ui-icon-triangle-1-s") + 
        template.content_tag(:span, "", :class => "ui-button-text")
      end
    end
    
    def pbcore_instantiation_format_input(method, options)
      radio_options = options.clone
      radio_options.delete(:input_html)
      radio_options[:label] = "Type"
      radio_input(method.to_s.gsub(/_name/, '_type').to_sym, radio_options) <<
      template.content_tag(:fieldset) do
        basic_input_helper(:text_field, :string, method, options) +
        template.content_tag(:button, :type => :button, :class => "pbcore-combobox-button ui-button ui-widget ui-state-default ui-button-icon-only ui-corner-right ui-button-icon") do
          template.content_tag(:span, "", :class => "ui-button-icon-primary ui-icon ui-icon-triangle-1-s") + 
          template.content_tag(:span, "", :class => "ui-button-text")
        end
      end
    end
  end
end
