#
# YES. This is very lame.
#
# But in an attempt to keep the 'core' data model as close to PBCore as possible,
# we have this separate table which helps the UI.
#
class ExtensionName < ActiveRecord::Base
  before_save :synthesize_description

  def synthesize_description
    if description.nil? || description.empty
      self.description = if extension_key.nil?
        extension_authority
      elsif extension_authority.nil?
        extension_key
      else
        "#{extension_key} (#{extension_authority})"
      end
    end
  end
end
