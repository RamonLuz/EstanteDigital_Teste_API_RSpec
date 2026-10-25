require "dotenv/load"
require "json"
require "json_schemer"
require "securerandom"
require "uri"
require "webmock/rspec"
require_relative "../lib/estante_digital_api"
require_relative "support/api_test_base"
require_relative "support/request_data"

WebMock.disable_net_connect!(
  allow: [URI.parse(EstanteDigital::Environment.configuration.base_url).host]
)

RSpec.configure do |config|
  config.include ApiTestBase
  config.run_all_when_everything_filtered = false

  config.filter_run_excluding api: true unless ENV["API_TESTS"] == "true"
  unless ENV["API_ALLOW_MUTATIONS"] == "true"
    config.filter_run_excluding mutating: true
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
end
