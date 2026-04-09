require "application_system_test_case"

class ImportQuotesTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper

  setup do
    Quote.delete_all
    Customer.delete_all
    Supplier.delete_all
    Region.delete_all
    @original_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :inline
  end

  teardown do
    ActiveJob::Base.queue_adapter = @original_adapter
  end

  test "upload CSV and verify quotes appear" do
    visit new_import_path

    assert_selector "h1", text: "Import Quotes"

    attach_file "file", Rails.root.join("test/fixtures/files/valid_quotes.csv")
    click_on "Upload"

    assert_selector "h1", text: "Quotes"
    assert_text "Fictora Consulting Group"
    assert_text "Yukon Electric"
    assert_text "Good Energy"
  end
end
