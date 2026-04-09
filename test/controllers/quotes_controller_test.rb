require "test_helper"

class QuotesControllerTest < ActionDispatch::IntegrationTest
  test "renders quotes index" do
    get quotes_path
    assert_response :success
  end

  test "root redirects to quotes index" do
    get root_path
    assert_response :success
  end
end
