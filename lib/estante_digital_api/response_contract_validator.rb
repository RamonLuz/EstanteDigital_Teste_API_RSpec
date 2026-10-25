require "json"
require "json_schemer"
require "pathname"
require "uri"

module EstanteDigital
  class ResponseContractValidator
    CONTRACTS_ROOT = Pathname(__dir__)
      .join("../../spec/contracts")
      .expand_path
      .freeze

    def validate_response!(method:, path:, response:)
      status = response.code
      if [204, 404].include?(status)
        unless response.body.to_s.empty?
          raise ContractViolation, "HTTP #{status} deveria retornar corpo vazio"
        end

        return
      end

      contract_path = contract_for(method: method, path: path, status: status)
      schema_path = CONTRACTS_ROOT.join(contract_path)
      unless schema_path.file?
        raise ContractViolation, "Contrato JSON nao encontrado: #{schema_path}"
      end

      validate_schema!(response.body, contract_path, expected_status: status)
    rescue JSON::ParserError => error
      raise ContractViolation,
            "Resposta nao contem JSON valido: #{error.message}"
    end

    def validate_schema!(body, contract_path, expected_status: nil)
      schema_path = CONTRACTS_ROOT.join(contract_path)
      unless schema_path.file?
        raise ContractViolation, "Contrato JSON nao encontrado: #{schema_path}"
      end

      document = JSON.parse(body)
      errors = JSONSchemer.schema(JSON.parse(schema_path.read))
        .validate(document)
        .map { |error| "#{error['data_pointer']}: #{error['error']}" }

      status_mismatch = expected_status &&
                        document.is_a?(Hash) &&
                        document["status"] != expected_status
      if status_mismatch
        received_status = document["status"].inspect
        errors << "status: esperado #{expected_status}, " \
                  "recebido #{received_status}"
      end

      unless errors.empty?
        message = "Resposta nao corresponde a #{contract_path}:\n" \
                  "#{errors.join("\n")}"
        raise ContractViolation, message
      end
    rescue JSON::ParserError => error
      raise ContractViolation,
            "JSON invalido ao validar #{contract_path}: #{error.message}"
    end

    private

    def contract_for(method:, path:, status:)
      return "common/api-error.json" if status == 400

      segments = URI.parse(path).path.split("/").reject(&:empty?)
      resource = segments.fetch(0, nil)
      collection = segments.length == 1
      normalized_method = method.to_s.upcase

      if resource == "health" && normalized_method == "GET" && status == 200
        return "health/get/health.json"
      end

      if resource == "sales"
        if normalized_method == "GET" && collection && status == 200
          return "sales/get-all/sale-list.json"
        end
        if normalized_method == "POST" && collection && status == 201
          return "sales/post/sale-created.json"
        end
        if normalized_method == "GET" && !collection && status == 200
          return "sales/post/sale-created.json"
        end
      elsif %w[books customers employees].include?(resource)
        singular = {
          "books" => "book",
          "customers" => "customer",
          "employees" => "employee"
        }.fetch(resource)
        if normalized_method == "GET" && collection && status == 200
          return "#{resource}/get-all/#{singular}-list.json"
        end
        if normalized_method == "GET" && !collection && status == 200
          return "#{resource}/post/#{singular}-created.json"
        end
        if normalized_method == "POST" && collection && status == 201
          return "#{resource}/post/#{singular}-created.json"
        end
        if normalized_method == "PUT" && !collection && status == 200
          return "#{resource}/post/#{singular}-created.json"
        end
      end

      raise ContractViolation,
            "Contrato nao configurado para #{normalized_method} " \
            "#{path} com HTTP #{status}"
    rescue URI::InvalidURIError => error
      raise ContractViolation,
            "Rota invalida ao selecionar contrato: #{error.message}"
    end
  end

  class ContractViolation < StandardError
  end
end
