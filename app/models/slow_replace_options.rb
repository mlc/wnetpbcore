# Not a subclass of ActiveRecord::Base
# Just a helper class to validate form submission
class SlowReplaceOptions
  attr_accessor :field, :from, :to, :user

  def initialize(hash = {})
    ihash = hash.with_indifferent_access
    self.field = ihash[:field]
    self.from = ihash[:from]
    self.to = ihash[:to]
  end

  def to_slow_replacer
    SlowReplacer.new(field, from, to, user.id)
  end

  def valid?
    SlowReplacer.allowed_fields.include?(self.field) &&
      !self.from.nil? && !self.from.empty? &&
      !self.to.nil? && !self.to.empty?
  end
end
