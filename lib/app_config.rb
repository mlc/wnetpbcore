module PBCore
  def self.config
    @config
  end

  def self.load_config!
    begin
      json_config = ActiveSupport::JSON.decode(File.read(File.join(RAILS_ROOT, "config", "application.json")))
      @config = json_config.with_indifferent_access
    rescue
      warn "App config config/application.json could not be loaded: #{$!}" 
      exit(1)
      # @config = HashWithIndifferentAccess.new
    end

    @config.freeze
  end
end
