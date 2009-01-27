class Extension < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset
  after_create :extension_name

  xml_string "extension"
  xml_string "extensionAuthorityUsed"

  def extension_key
    extension_key_value[0]
  end
  
  def extension_value
    extension_key_value[1]
  end

  # warning: unwanted results will occur if your key has a colon in it, or if
  # key is nil and value has a colon in it.
  def extension_key=(key)
    self.extension = key.nil? ? extension_value : "#{key}:#{extension_value}"
  end
  
  def extension_value=(value)
    self.extension = extension_key.nil? ? value : "#{extension_key}:#{value}"
  end

  def extension_name
    @extension_name ||= ExtensionName.find_or_create_by_extension_key_and_extension_authority(extension_key, extension_authority_used)
  end

  def extension_name_id
    extension_name.id
  end
  
  def extension_name=(value)
    @extension_name = value
    self.extension_key = value.extension_key
    self.extension_authority_used = value.extension_authority
  end

  def extension_name_id=(value)
    self.extension_name = ExtensionName.find(value)
  end

  protected
  def extension_key_value
    answer = extension.split(/:/, 2)
    answer.size == 1 ? [nil, answer[0]] : answer
  end
end
