class DateAvailable < ActiveRecord::Base
  include PbcoreXmlElement
  belongs_to :instantiation
  
  xml_string "dateAvailableStart"
  xml_string "dateAvailableEnd"
  
  def to_s
    if date_available_start.empty?
      if date_available_end.empty?
        "undefined"
      else
        "until #{date_available_end}"
      end
    else
      if date_available_end.empty?
        "from #{date_available_start}"
      else
        "#{date_available_start} – #{date_available_end}"
      end
    end
  end
end
