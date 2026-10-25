require "spec_helper"

RSpec.describe EstanteDigital::HttpClient do
  let(:configuration) do
    EstanteDigital::Configuration.new(
      env: {
        "API_BASE_URL" => "http://api.example.test/v1",
        "API_TIMEOUT_SECONDS" => "3"
      }
    )
  end
  let(:client) { described_class.new(configuration: configuration) }

  it "sends a GET request to the configured API and returns its response" do
    stub_request(:get, "http://api.example.test/v1/health")
      .with(headers: { "Accept" => "application/json" })
      .to_return(
        status: 200,
        body: '{"status":"ok"}',
        headers: { "Content-Type" => "application/json" }
      )

    response = client.get("/health")

    expect(response.code).to eq(200)
    expect(JSON.parse(response.body)).to eq("status" => "ok")
  end

  it "serializes request bodies as JSON" do
    stub_request(:post, "http://api.example.test/v1/books")
      .with(
        body: '{"title":"Clean Code"}',
        headers: { "Content-Type" => "application/json" }
      )
      .to_return(status: 201)

    response = client.post("/books", body: { title: "Clean Code" })

    expect(response.code).to eq(201)
  end

  it "rejects absolute request URLs" do
    expect do
      client.get("https://other.example.test/health")
    end.to raise_error(ArgumentError, /must be relative/)
  end

  it "rejects unsupported HTTP methods" do
    expect do
      client.request(method: :options, path: "/health")
    end.to raise_error(ArgumentError, /Unsupported HTTP method/)
  end
end
