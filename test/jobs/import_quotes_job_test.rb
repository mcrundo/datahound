require "test_helper"

class ImportQuotesJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    Quote.delete_all
    Customer.delete_all
    Supplier.delete_all
    Region.delete_all
  end

  def create_import(file_name)
    import = Import.new
    import.file.attach(
      io: File.open(Rails.root.join("test/fixtures/files/#{file_name}")),
      filename: file_name,
      content_type: "text/csv"
    )
    import.save!
    import
  end

  test "delegates to QuotesImporter" do
    import = create_import("valid_quotes.csv")

    perform_enqueued_jobs do
      ImportQuotesJob.perform_later(import.id)
    end

    assert_equal 4, Quote.count
    assert_equal "completed", import.reload.status
  end

  test "discards on missing import record" do
    perform_enqueued_jobs do
      ImportQuotesJob.perform_later(0)
    end

    assert_equal 0, Quote.count
  end

  test "enqueues on the default queue" do
    import = create_import("valid_quotes.csv")

    assert_enqueued_with(queue: "default") do
      ImportQuotesJob.perform_later(import.id)
    end
  end
end
