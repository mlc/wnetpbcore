ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
end

module Test::Unit::Assertions
  def assert_not_empty(object, message="")
    full_message = build_message(message, "<?> expected to not be empty.", object)
    assert_block(full_message){!object.nil? && !object.empty?}
  end
end
