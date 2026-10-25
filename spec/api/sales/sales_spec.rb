RSpec.describe "Sales API", :api do
  it "lists sales using the response contract" do
    response = api_request(:get, "/sales")

    expect(response.code).to eq(200)
    expect_contract(response, "sales/get-all/sale-list.json")
  end

  it "returns not found for an unknown sale" do
    response = api_request(:get, "/sales/999999999")

    expect(response.code).to eq(404)
    expect(response.body).to be_empty
  end

  it "rejects a sale with missing required fields" do
    response = api_request(:post, "/sales")

    expect(response.code).to eq(400)
    expect_contract(response, "sales/post/sale-invalid.json")
  end
end
