require "securerandom"

Before do
  @api_client = EstanteDigital::Environment.api_client
  @response = nil
  @unique = SecureRandom.random_number(10**11).to_s.rjust(11, "0")
  @registration = SecureRandom.random_number(900_000) + 100_000
  @created_resources = []
end

Before("@mutating") do
  unless ENV["API_ALLOW_MUTATIONS"] == "true"
    raise "Cenarios @mutating exigem API_ALLOW_MUTATIONS=true " \
          "e uma base descartavel"
  end
end

After("@mutating") do |scenario|
  next if scenario.source_tag_names.include?("@preserve_data")

  failures = @created_resources.reverse_each.filter_map do |path|
    response = @api_client.request(method: :delete, path: path)
    next if [204, 404].include?(response.code)

    "Falha ao limpar #{path}: HTTP #{response.code}"
  end
  raise failures.join("\n") unless failures.empty?
end
