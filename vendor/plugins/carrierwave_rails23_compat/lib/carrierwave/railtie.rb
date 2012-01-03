# Stubbing out Rails::Railtie, which is not present in Rails 2.3.
# Any code defined in initializer block will be called immediately.
#
# Carrierwave defintes a Railtie that looks like this:
#
#     module CarrierWave
#       class Railtie < Rails::Railtie
#         initializer "carrierwave.setup_paths" do
#           CarrierWave.root = Rails.root.join(Rails.public_path).to_s
#         end
#       end
#     end
module CarrierWave
  class Rails::Railtie
    def self.initializer *args
      yield
    end
  end
end
