RSpec.describe "Employees API", :api do
  it "lists employees using the response contract" do
    response = api_request(:get, "/employees")

    expect(response.code).to eq(200)
    expect_contract(response, "employees/get-all/employee-list.json")
  end

  it "returns not found for an unknown employee" do
    response = api_request(:get, "/employees/999999999")

    expect(response.code).to eq(404)
    expect(response.body).to be_empty
  end

  it "rejects an employee with missing required fields" do
    response = api_request(:post, "/employees")

    expect(response.code).to eq(400)
  end

  it "creates an employee and matches its response contract", :mutating do
    request_body = RequestData.employee
    response = api_request(:post, "/employees", body: request_body)
    track_created_resource(response, "/employees")

    expect(response.code).to eq(201)
    expect_contract(response, "employees/post/employee-created.json")
    expect(JSON.parse(response.body)).to include("cpf" => request_body[:cpf])
  end

  it "returns not found when updating an unknown employee" do
    response = api_request(
      :put,
      "/employees/999999999",
      body: RequestData.employee
    )

    expect(response.code).to eq(404)
    expect(response.body).to be_empty
  end

  it "returns not found when deleting an unknown employee" do
    response = api_request(:delete, "/employees/999999999")

    expect(response.code).to eq(404)
    expect(response.body).to be_empty
  end
end
