require "application_system_test_case"

class FilterQuotesTest < ApplicationSystemTestCase
  test "filter by state narrows results" do
    visit quotes_path

    select "MA", from: "region"

    assert_text "Fictora Consulting Group"
    assert_no_text "NullPoint Enterprises"
  end

  test "filter by tax included" do
    visit quotes_path

    select "Yes", from: "tax_included"

    assert_text "Yes"
  end

  test "clear filters resets the view" do
    visit quotes_path(region: "MA")

    click_on "Clear"

    assert_current_path quotes_path
  end
end
