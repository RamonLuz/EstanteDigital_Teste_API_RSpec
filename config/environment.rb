require "dotenv/load"
require_relative "../lib/estante_digital_api"

module EstanteDigital
  module Environment
    module_function

    def configuration
      @configuration ||= Configuration.new
    end

    def api_client
      @api_client ||= HttpClient.new(configuration: configuration)
    end
  end
end
