require "test_helper"

class CustomersControllerTest < ActionDispatch::IntegrationTest
  test "renders customer summary" do
    get customers_path
    assert_response :success
  end

  test "displays customer names" do
    get customers_path
    assert_match customers(:fictora).name, response.body
  end

  test "displays aggregate stats" do
    get customers_path
    assert_select ".card", minimum: 1
  end

  test "highlights best quote supplier" do
    get customers_path
    assert_match "Best:", response.body
  end
end
