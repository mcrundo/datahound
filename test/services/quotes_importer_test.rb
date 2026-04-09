require "test_helper"

class QuotesImporterTest < ActiveSupport::TestCase
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

  # -- successful imports --

  test "imports valid CSV and creates all records" do
    import = create_import("valid_quotes.csv")
    result = QuotesImporter.new.import_quotes(import.id)

    assert result.all_rows_imported?
    assert_empty result.errors
    assert_equal 2, Region.count
    assert_equal 2, Customer.count
    assert_equal 4, Supplier.count
    assert_equal 4, Quote.count
    assert_equal "completed", import.reload.status
  end

  test "computes normalized_rate for tax-included quotes" do
    import = create_import("valid_quotes.csv")
    QuotesImporter.new.import_quotes(import.id)

    quote = Quote.joins(:customer, :supplier)
      .where(customers: { name: "Fictora Consulting Group" })
      .where(suppliers: { name: "Yukon Electric" })
      .first

    rate = BigDecimal("0.0662")
    tax_rate = BigDecimal("7.5")
    expected = rate / (1 + tax_rate / 100)
    assert_in_delta expected.to_f, quote.normalized_rate.to_f, 0.000001
  end

  test "stores rate as-is for tax-excluded quotes" do
    import = create_import("valid_quotes.csv")
    QuotesImporter.new.import_quotes(import.id)

    quote = Quote.joins(:customer, :supplier)
      .where(customers: { name: "Fictora Consulting Group" })
      .where(suppliers: { name: "Good Energy" })
      .first

    assert_in_delta 0.0723, quote.normalized_rate.to_f, 0.000001
  end

  test "handles zero tax rate" do
    import = create_import("valid_quotes.csv")
    QuotesImporter.new.import_quotes(import.id)

    quote = Quote.joins(:customer, :supplier)
      .where(customers: { name: "Fictora Consulting Group" })
      .where(suppliers: { name: "Good Energy" })
      .first

    assert_equal quote.rate, quote.normalized_rate
  end

  # -- idempotency and updates --

  test "re-importing same file is idempotent" do
    import1 = create_import("valid_quotes.csv")
    import2 = create_import("valid_quotes.csv")
    QuotesImporter.new.import_quotes(import1.id)
    QuotesImporter.new.import_quotes(import2.id)

    assert_equal 4, Quote.count
  end

  test "updates existing quotes with new values" do
    import1 = create_import("valid_quotes.csv")
    import2 = create_import("updated_quotes.csv")
    QuotesImporter.new.import_quotes(import1.id)
    QuotesImporter.new.import_quotes(import2.id)

    quote = Quote.joins(:customer, :supplier)
      .where(customers: { name: "Fictora Consulting Group" })
      .where(suppliers: { name: "Yukon Electric" })
      .first

    assert_equal false, quote.tax_included
    assert_in_delta 0.0750, quote.rate.to_f, 0.000001
  end

  # -- error handling --

  test "collects row-level errors and continues importing" do
    import = create_import("malformed_quotes.csv")
    result = QuotesImporter.new.import_quotes(import.id)

    assert_not result.all_rows_imported?
    assert_equal 1, result.errors.size
    assert_match(/Row error/, result.errors.first)
    assert_equal 1, Quote.count
    assert_equal "completed", import.reload.status
  end

  test "handles duplicate rows within file by keeping last" do
    import = create_import("duplicate_quotes.csv")
    QuotesImporter.new.import_quotes(import.id)

    assert_equal 1, Quote.count
    assert_in_delta 0.0700, Quote.first.rate.to_f, 0.000001
  end

  test "marks import as failed on bad headers" do
    import = create_import("bad_headers.csv")
    result = QuotesImporter.new.import_quotes(import.id)

    assert_not result.all_rows_imported?
    assert_equal "failed", import.reload.status
  end
end
