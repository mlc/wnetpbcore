#require 'action_view/helpers/form_tag_helper'
module FormtasticCustomizations
  class PbcoreFormBuilder < Formtastic::SemanticFormBuilder
    
    def pbcore_combobox_input(method, options)
      basic_input_helper(:text_field, :string, method, options) <<
      template.content_tag(:button, :type => :button, :class => "pbcore-combobox-button") do
        "&#9660;" # Black down pointing arrow
      end
    end
  end
end