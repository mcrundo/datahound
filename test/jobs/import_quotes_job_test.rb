require "test_helper"

class ImportQuotesJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  setup do
    Quote.delete_all
    Customer.delete_all
    Supplier.delete_all
    Region.delete_all
  end

  def fixture_file(name)
    Rails.root.join("test/fixtures/files/#{name}").to_s
  end

  test "delegates to QuotesImporter and imports quotes" do
    perform_enqueued_jobs do
      ImportQuotesJob.perform_later(fixture_file("valid_quotes.csv"))
    end

    assert_equal 4, Quote.count
  end

  test "handles row-level errors without raising" do
    perform_enqueued_jobs do
      ImportQuotesJob.perform_later(fixture_file("malformed_quotes.csv"))
    end

    assert_equal 1, Quote.count
  end

  test "discards on missing file" do
    perform_enqueued_jobs do
      ImportQuotesJob.perform_later("/nonexistent/file.csv")
    end

    assert_equal 0, Quote.count
  end

  test "discards on bad headers" do
    perform_enqueued_jobs do
      ImportQuotesJob.perform_later(fixture_file("bad_headers.csv"))
    end

    assert_equal 0, Quote.count
  end

  test "enqueues on the default queue" do
    assert_enqueued_with(queue: "default") do
      ImportQuotesJob.perform_later(fixture_file("valid_quotes.csv"))
    end
  end
end
