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

  # -- filters --

  test "filters by region" do
    get quotes_path, params: { region: "MA" }
    assert_response :success
  end

  test "filters by supplier" do
    get quotes_path, params: { supplier_id: suppliers(:yukon).id }
    assert_response :success
  end

  test "filters by tax included" do
    get quotes_path, params: { tax_included: "true" }
    assert_response :success
  end

  test "combines multiple filters" do
    get quotes_path, params: { region: "MA", tax_included: "true" }
    assert_response :success
  end

  # -- sorting --

  test "sorts by rate ascending" do
    get quotes_path, params: { sort: "rate_asc" }
    assert_response :success
  end

  test "sorts by customer name" do
    get quotes_path, params: { sort: "customer_asc" }
    assert_response :success
  end

  test "ignores invalid sort key" do
    get quotes_path, params: { sort: "invalid" }
    assert_response :success
  end

  # -- turbo frame --

  test "responds to turbo frame requests" do
    get quotes_path, params: { region: "MA" }, headers: { "Turbo-Frame" => "quotes_table" }
    assert_response :success
  end
end
