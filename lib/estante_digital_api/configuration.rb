require "uri"

module EstanteDigital
  class Configuration
    attr_reader :base_url, :timeout

    def initialize(env: ENV)
      @base_url = normalize_base_url(
        env.fetch("API_BASE_URL", "http://localhost:8080")
      )
      @timeout = parse_timeout(env.fetch("API_TIMEOUT_SECONDS", "10"))
    end

    private

    def normalize_base_url(value)
      url = value.to_s.strip
      uri = URI.parse(url)

      valid_url = (
        %w[http https].include?(uri.scheme) &&
        uri.host &&
        uri.userinfo.nil? &&
        uri.query.nil? &&
        uri.fragment.nil?
      )
      unless valid_url
        raise ArgumentError,
              "API_BASE_URL must be an absolute HTTP(S) " \
              "URL without credentials, query, or fragment"
      end

      url.sub(%r{/+\z}, "")
    rescue URI::InvalidURIError => error
      raise ArgumentError, "API_BASE_URL is invalid: #{error.message}"
    end

    def parse_timeout(value)
      timeout = Integer(value.to_s, 10)
      raise ArgumentError unless timeout.positive?

      timeout
    rescue ArgumentError, TypeError
      raise ArgumentError, "API_TIMEOUT_SECONDS must be a positive integer"
    end
  end
end
