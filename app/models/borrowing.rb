class Borrowing < ActiveRecord::Base
  belongs_to :instantiation

  def active?
    returned.nil?
  end
end