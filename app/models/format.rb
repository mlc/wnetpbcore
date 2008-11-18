class Format < ActiveRecord::Base
  has_many :instantiations

  def safe_to_delete?
    instantiations.size == 0
  end
end
