require "application_system_test_case"

class CustomerSummaryTest < ApplicationSystemTestCase
  test "displays customer summary cards" do
    visit customers_path

    assert_selector "h1", text: "Customer Summary"
    assert_text "Fictora Consulting Group"
    assert_text "NullPoint Enterprises"
  end

  test "shows aggregated stats" do
    visit customers_path

    assert_text "Best Rate"
    assert_text "Avg Rate"
    assert_text "Spread"
  end

  test "highlights best quote supplier" do
    visit customers_path

    assert_text "Best:"
  end

  test "navigates between quotes and customers" do
    visit quotes_path

    click_on "Customers"
    assert_selector "h1", text: "Customer Summary"

    click_on "All Quotes"
    assert_selector "h1", text: "Quotes"
  end
end
