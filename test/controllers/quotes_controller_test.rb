require "test_helper"

class QuotesControllerTest < ActionDispatch::IntegrationTest
  test "renders quotes index" do
    get quotes_path
    assert_response :success
  end

  test "root routes to quotes index" do
    get root_path
    assert_response :success
  end

  test "displays all CSV columns" do
    get quotes_path

    assert_select "th", text: "Customer"
    assert_select "th", text: "Supplier"
    assert_select "th", text: "Quote"
    assert_select "th", text: "Tax Included"
    assert_select "th", text: "State"
    assert_select "th", text: "Tax Rate"
    assert_select "th", text: "Normalized Rate"
  end

  test "paginates results" do
    get quotes_path, params: { page: 1 }
    assert_response :success
  end
end
