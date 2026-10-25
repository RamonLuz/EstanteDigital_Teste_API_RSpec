require "rspec/expectations"

# Carrega a configuracao antes dos helpers que usam o cliente da API.
require_relative "../../config/environment"
require_relative "api_step_helpers"

# Disponibiliza matchers e metodos auxiliares em cada cenario Cucumber.
World(RSpec::Matchers)
World(ApiStepHelpers)
