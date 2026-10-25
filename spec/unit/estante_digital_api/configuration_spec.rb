require "spec_helper"

RSpec.describe EstanteDigital::Configuration do
  describe "#initialize" do
    it "normalizes a valid base URL" do
      configuration = described_class.new(
        env: {
          "API_BASE_URL" => "https://api.example.test/v1/",
          "API_TIMEOUT_SECONDS" => "5"
        }
      )

      expect(configuration.base_url).to eq("https://api.example.test/v1")
      expect(configuration.timeout).to eq(5)
    end

    it "rejects a base URL containing credentials" do
      expect do
        described_class.new(
          env: {
            "API_BASE_URL" => "https://user:secret@api.example.test",
            "API_TIMEOUT_SECONDS" => "5"
          }
        )
      end.to raise_error(ArgumentError, /API_BASE_URL/)
    end

    it "rejects a non-positive timeout" do
      expect do
        described_class.new(
          env: {
            "API_BASE_URL" => "http://api.example.test",
            "API_TIMEOUT_SECONDS" => "0"
          }
        )
      end.to raise_error(ArgumentError, /positive integer/)
    end
  end
end
