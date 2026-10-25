require "httparty"
require "json"
require "uri"

module EstanteDigital
  class HttpClient
    HTTP_METHODS = %i[get post put patch delete].freeze
    DEFAULT_HEADERS = {
      "Accept" => "application/json",
      "Content-Type" => "application/json"
    }.freeze

    def initialize(configuration:)
      @configuration = configuration
    end

    HTTP_METHODS.each do |http_method|
      define_method(http_method) do |path, **options|
        request(method: http_method, path: path, **options)
      end
    end

    def request(method:, path:, headers: {}, query: nil, body: nil)
      method = method.to_sym
      unless HTTP_METHODS.include?(method)
        raise ArgumentError, "Unsupported HTTP method: #{method}"
      end

      options = {
        headers: DEFAULT_HEADERS.merge(headers),
        open_timeout: @configuration.timeout,
        read_timeout: @configuration.timeout
      }
      options[:query] = query unless query.nil?
      options[:body] = JSON.generate(body) unless body.nil?

      HTTParty.public_send(method, build_url(path), options)
    end

    private

    def build_url(path)
      request_path = path.to_s
      uri = URI.parse(request_path)
      if uri.absolute? || request_path.start_with?("//")
        raise ArgumentError, "Request path must be relative to API_BASE_URL"
      end

      base_url = "#{@configuration.base_url}/"
      relative_path = request_path.sub(%r{\A/}, "")
      URI.join(base_url, relative_path).to_s
    rescue URI::InvalidURIError => error
      raise ArgumentError, "Request path is invalid: #{error.message}"
    end
  end
end
