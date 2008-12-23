class Extension < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :asset

  xml_string "extension"
  xml_string "extensionAuthorityUsed"

  def extension_key
    extension_key_value[0]
  end
  
  def extension_value
    extension_key_value[1]
  end

  # warning: unwanted results will occur if your key has a colon in it.
  def extension_key=(key)
    self.extension = key.nil? ? extension_value : "#{key}:#{extension_value}"
  end
  
  def extension_value=(value)
    self.extension = extension_key.nil? ? value : "#{extension_key}:#{value}"
  end
  
  protected
  def extension_key_value
    answer = extension.split(/:/, 2)
    answer.size == 1 ? [nil, answer[0]] : answer
  end
end
