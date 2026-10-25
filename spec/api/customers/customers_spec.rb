RSpec.describe "Customers API", :api do
  it "lists customers using the response contract" do
    response = api_request(:get, "/customers")

    expect(response.code).to eq(200)
    expect_contract(response, "customers/get-all/customer-list.json")
  end

  it "returns not found for an unknown customer" do
    response = api_request(:get, "/customers/999999999")

    expect(response.code).to eq(404)
    expect(response.body).to be_empty
  end

  it "rejects a customer with missing required fields" do
    response = api_request(:post, "/customers")

    expect(response.code).to eq(400)
  end

  it "creates a customer and matches its response contract", :mutating do
    request_body = RequestData.customer
    response = api_request(:post, "/customers", body: request_body)
    track_created_resource(response, "/customers")

    expect(response.code).to eq(201)
    expect_contract(response, "customers/post/customer-created.json")
    expect(JSON.parse(response.body)).to include("cpf" => request_body[:cpf])
  end

  it "returns not found when updating an unknown customer" do
    response = api_request(
      :put,
      "/customers/999999999",
      body: RequestData.customer
    )

    expect(response.code).to eq(404)
    expect(response.body).to be_empty
  end

  it "returns not found when deleting an unknown customer" do
    response = api_request(:delete, "/customers/999999999")

    expect(response.code).to eq(404)
    expect(response.body).to be_empty
  end
end
