require "spec_helper"

RSpec.describe EstanteDigital::ResponseContractValidator do
  it "validates the health response contract" do
    body = '{"status":"UP","application":"estantedigital"}'
    response = Struct.new(:code, :body).new(200, body)

    expect do
      described_class.new.validate_response!(
        method: :get,
        path: "/health",
        response: response
      )
    end.not_to raise_error
  end

  it "validates the error contract against the HTTP status" do
    body = '{"status":400,"message":"Invalid request","field":"Body"}'
    response = Struct.new(:code, :body).new(400, body)

    expect do
      described_class.new.validate_response!(
        method: :post,
        path: "/customers",
        response: response
      )
    end.not_to raise_error
  end

  it "rejects an error body whose status differs from the HTTP status" do
    body = '{"status":404,"message":"Invalid request","field":"Body"}'
    response = Struct.new(:code, :body).new(400, body)

    expect do
      described_class.new.validate_response!(
        method: :post,
        path: "/customers",
        response: response
      )
    end.to raise_error(EstanteDigital::ContractViolation, /status/)
  end

  it "requires empty bodies for responses without content" do
    response = Struct.new(:code, :body).new(404, '{"message":"Not found"}')

    expect do
      described_class.new.validate_response!(
        method: :get,
        path: "/customers/999",
        response: response
      )
    end.to raise_error(EstanteDigital::ContractViolation, /corpo vazio/)
  end
end
