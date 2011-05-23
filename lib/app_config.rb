module PBCore
  def self.config
    @config
  end

  def self.load_config!
    begin
      json_config = ActiveSupport::JSON.decode(File.read(File.join(RAILS_ROOT, "config", "application.json")))
      @config = json_config.with_indifferent_access
      @config['request_email'] = @config['request_email'].join("%2c") if @config['request_email'] && @config['request_email'].respond_to?(:join)
    rescue
      @config = HashWithIndifferentAccess.new
    end

    @config.freeze
  end
end
