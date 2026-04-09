require "test_helper"

class ImportsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  def fixture_file(name, content_type: "text/csv")
    Rack::Test::UploadedFile.new(
      Rails.root.join("test/fixtures/files/#{name}"),
      content_type
    )
  end

  # -- new --

  test "renders upload form" do
    get new_import_path
    assert_response :success
  end

  # -- create --

  test "creates import record and enqueues job" do
    assert_enqueued_with(job: ImportQuotesJob) do
      post imports_path, params: { import: { file: fixture_file("valid_quotes.csv") } }
    end

    import = Import.last
    assert import.file.attached?
    assert_equal "pending", import.status

    assert_redirected_to quotes_path
    follow_redirect!
    assert_match(/Import started/, response.body)
  end

  test "rejects missing file" do
    post imports_path, params: { import: { file: "" } }

    assert_response :unprocessable_entity
    assert_match(/Please select/, response.body)
  end

  test "rejects non-CSV file" do
    post imports_path, params: { import: { file: fixture_file("valid_quotes.csv", content_type: "application/pdf") } }

    assert_response :unprocessable_entity
    assert_match(/must be a CSV/, response.body)
  end
end
