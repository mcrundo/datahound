require "application_system_test_case"

class QuotesIndexTest < ApplicationSystemTestCase
  test "displays quotes with all columns" do
    visit quotes_path

    assert_selector "th", text: "Customer"
    assert_selector "th", text: "Supplier"
    assert_selector "th", text: "Quote"
    assert_selector "th", text: "Tax Included"
    assert_selector "th", text: "State"
    assert_selector "th", text: "Tax Rate"
    assert_selector "th", text: "Normalized Rate"
  end

  test "shows empty state when no quotes" do
    Quote.delete_all

    visit quotes_path

    assert_text "No quotes yet"
    assert_selector "a", text: "Import your first CSV"
  end

  test "displays fixture quote data" do
    visit quotes_path

    assert_text quotes(:fictora_yukon).customer.name
    assert_text quotes(:fictora_yukon).supplier.name
  end
end
