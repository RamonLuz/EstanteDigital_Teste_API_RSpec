RSpec.describe "Books API", :api do
  it "lists books using the response contract" do
    response = api_request(:get, "/books")

    expect(response.code).to eq(200)
    expect_contract(response, "books/get-all/book-list.json")
  end

  it "returns not found for an unknown book" do
    response = api_request(:get, "/books/999999999")

    expect(response.code).to eq(404)
    expect(response.body).to be_empty
  end

  it "rejects a book with a blank title" do
    invalid_book = RequestData.book.merge(title: " ")
    response = api_request(:post, "/books", body: invalid_book)

    expect(response.code).to eq(400)
  end

  it "creates a book and matches its response contract", :mutating do
    request_body = RequestData.book
    response = api_request(:post, "/books", body: request_body)
    track_created_resource(response, "/books")

    expect(response.code).to eq(201)
    expect_contract(response, "books/post/book-created.json")
    expect(JSON.parse(response.body)).to include(
      "title" => request_body[:title]
    )
  end

  it "returns not found when updating an unknown book" do
    response = api_request(:put, "/books/999999999", body: RequestData.book)

    expect(response.code).to eq(404)
    expect(response.body).to be_empty
  end

  it "returns not found when deleting an unknown book" do
    response = api_request(:delete, "/books/999999999")

    expect(response.code).to eq(404)
    expect(response.body).to be_empty
  end
end
