require "json"
require "pathname"
require "uri"

module ApiStepHelpers
  PAYLOADS_ROOT = Pathname(__dir__).join("..", "api").expand_path.freeze

  def send_api_request(method, path, body: nil)
    resolved_path = resolve_placeholders(path)
    @response = @api_client.request(
      method: method.downcase.to_sym,
      path: resolved_path,
      body: body
    )
    track_created_resource(method, resolved_path, @response)
    EstanteDigital::ResponseContractValidator.new.validate_response!(
      method: method,
      path: resolved_path,
      response: @response
    )
  end

  def load_payload(relative_path)
    path = PAYLOADS_ROOT.join(relative_path).cleanpath
    inside_payload_directory = path.to_s.start_with?(
      "#{PAYLOADS_ROOT}#{File::SEPARATOR}"
    )
    unless inside_payload_directory && path.file?
      raise ArgumentError, "Payload nao encontrado: #{relative_path}"
    end

    JSON.parse(resolve_placeholders(path.read))
  end

  def mutate_payload!(payload, field, mutation)
    unless payload.is_a?(Hash)
      raise ArgumentError, "Payload precisa ser um objeto JSON"
    end
    unless payload.key?(field)
      raise ArgumentError, "Campo JSON nao encontrado: #{field}"
    end

    case mutation
    when "blank" then payload[field] = ""
    when "whitespace" then payload[field] = "   "
    when "null" then payload[field] = nil
    when "missing" then payload.delete(field)
    when "invalid-cpf" then payload[field] = "123"
    when "too-long-cpf" then payload[field] = "123456789012"
    when "zero" then payload[field] = 0
    when "negative" then payload[field] = -1
    when "wrong-type" then payload[field] = "tipo-invalido"
    when "invalid-date" then payload[field] = "data-invalida"
    when "empty-array" then payload[field] = []
    else raise ArgumentError, "Mutacao JSON desconhecida: #{mutation}"
    end
  end

  def track_created_resource(method, path, response)
    return unless method.casecmp("POST").zero? && response.code == 201

    resource = URI.parse(path).path.split("/").reject(&:empty?).first
    id = JSON.parse(response.body).fetch("id")
    @last_id = id.to_s
    if %w[books customers employees].include?(resource)
      @created_resources << "/#{resource}/#{id}"
    end
  end

  def response_json
    JSON.parse(@response.body)
  end

  def json_value(document, path)
    path.split(".").reduce(document) do |value, key|
      unless value.is_a?(Hash) && value.key?(key)
        raise KeyError, "Campo JSON nao encontrado: #{path}"
      end

      value.fetch(key)
    end
  end

  def resolve_placeholders(value)
    value
      .gsub("${unique}", @unique)
      .gsub("${registration}", @registration.to_s)
      .gsub("${id}") do
        raise "Nenhum ID foi retornado neste cenario" unless @last_id

        @last_id
      end
  end
end
