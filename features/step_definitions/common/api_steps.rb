require "json"

When("envio uma requisição {string} para o endpoint {string}") do |method, path|
  send_api_request(method, path)
end

When("envio uma requisição {word} para {string}") do |method, path|
  send_api_request(method, path)
end

When(
  "envio uma requisição {string} para o endpoint {string} com o corpo JSON:"
) do |method, path, body|
  send_api_request(method, path, body: JSON.parse(resolve_placeholders(body)))
end

When(
  "envio uma requisição {word} para {string} com o payload {string}"
) do |method, path, payload_path|
  send_api_request(method, path, body: load_payload(payload_path))
end

When(
  "envio uma requisição {word} para {string} com o payload {string} " \
  "e altero o campo {string} para {string}"
) do |method, path, payload_path, field, mutation|
  payload = load_payload(payload_path)
  mutate_payload!(payload, field, mutation)
  send_api_request(method, path, body: payload)
end

Then("o status HTTP deve ser {int}") do |status|
  expect(@response).not_to be_nil
  expect(@response.code).to eq(status)
end

Then("a resposta JSON deve conter os campos {string}") do |fields|
  body = response_json
  expect(body).to be_a(Hash)
  expect(body.keys).to include(*fields.split(",").map(&:strip))
end

Then("o campo JSON {string} deve ser igual a {string}") do |field, expected|
  actual = json_value(response_json, field)
  expect(actual.to_s).to eq(resolve_placeholders(expected))
end

Then("a resposta JSON deve ser uma lista") do
  expect(response_json).to be_a(Array)
end

Then("o campo JSON {string} deve ser um numero positivo") do |field|
  value = json_value(response_json, field)
  expect(value).to be_a(Numeric)
  expect(value).to be_positive
end

Then("a lista JSON deve conter {string} no campo {string}") do |expected, field|
  values = response_json.map { |item| json_value(item, field) }
  expect(values).to include(resolve_placeholders(expected))
end
