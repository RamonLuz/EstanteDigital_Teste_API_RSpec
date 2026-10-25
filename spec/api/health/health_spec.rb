RSpec.describe "Health API", :api do
  it "reports that the application is available" do
    response = api_request(:get, "/health")

    expect(response.code).to eq(200)
    expect_contract(response, "health/get/health.json")
    expect(JSON.parse(response.body)).to include(
      "status" => "UP",
      "application" => "estantedigital"
    )
  end
end
