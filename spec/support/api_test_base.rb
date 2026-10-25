module ApiTestBase
  def api_request(method, path, body: nil, query: nil, headers: {})
    response = EstanteDigital::Environment.api_client.request(
      method: method,
      path: path,
      headers: headers,
      query: query,
      body: body
    )
    EstanteDigital::ResponseContractValidator.new.validate_response!(
      method: method,
      path: path,
      response: response
    )
    response
  end

  def expect_contract(response, contract_path)
    EstanteDigital::ResponseContractValidator.new.validate_schema!(
      response.body,
      contract_path
    )
  end

  def track_created_resource(response, collection_path)
    return unless response.code == 201

    resource_id = JSON.parse(response.body).fetch("id")
    (@created_resources ||= []) << "#{collection_path}/#{resource_id}"
  end

  def clean_up_created_resources
    failures = Array(@created_resources).reverse_each.filter_map do |path|
      response = api_request(:delete, path)
      next if [204, 404].include?(response.code)

      "Cleanup failed for #{path}: HTTP #{response.code}"
    end
    raise failures.join("\n") unless failures.empty?
  end
end

RSpec.configure do |config|
  config.after do
    clean_up_created_resources
  end
end
