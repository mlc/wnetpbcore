require 'ipaddr'

class IpBlock < ActiveRecord::Base
  has_many :users
  serialize :ranges, Array

  validates_presence_of :name
  def validate
    super
    if !ranges.kind_of?(Array)
      self.errors.add("ranges", "must be an array")
    elsif ranges.size < 1
      self.errors.add("ranges", "can't be empty")
    else
      ranges.all? do |range|
        range =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\/([1-3]?\d)$/ && $1.to_i < 256 && $2.to_i < 256 && $3.to_i < 256 && $4.to_i < 256 && $5.to_i <= 32
      end || self.errors.add("ranges", "must all be valid IP addresses and netmasks between 0 and 32 bits")
    end
  end

  def include?(address)
    ipaddr = IPAddr.new(address)
    ranges.any?{|range| IPAddr.new(range).include?(ipaddr)}
  end

  def ranges_str
    ranges.join(", ")
  end
  
  def set_ranges(ip_ranges, netmasks)
    self.ranges = (ip_ranges || []).zip((netmasks || [])).map{|ip_range, netmask| "#{ip_range}/#{netmask}"}
  end
end
