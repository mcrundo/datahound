require "test_helper"

class QuotesImporterTest < ActiveSupport::TestCase
  setup do
    Quote.delete_all
    Customer.delete_all
    Supplier.delete_all
    Region.delete_all
  end

  def fixture_file(name)
    Rails.root.join("test/fixtures/files/#{name}")
  end

  # -- successful imports --

  test "imports valid CSV and creates all records" do
    result = QuotesImporter.new.import_quotes(fixture_file("valid_quotes.csv"))

    assert result.all_rows_imported?
    assert_empty result.errors
    assert_equal 2, Region.count
    assert_equal 2, Customer.count
    assert_equal 4, Supplier.count
    assert_equal 4, Quote.count
  end

  test "computes normalized_rate for tax-included quotes" do
    QuotesImporter.new.import_quotes(fixture_file("valid_quotes.csv"))

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
    QuotesImporter.new.import_quotes(fixture_file("valid_quotes.csv"))

    quote = Quote.joins(:customer, :supplier)
      .where(customers: { name: "Fictora Consulting Group" })
      .where(suppliers: { name: "Good Energy" })
      .first

    assert_in_delta 0.0723, quote.normalized_rate.to_f, 0.000001
  end

  test "handles zero tax rate" do
    QuotesImporter.new.import_quotes(fixture_file("valid_quotes.csv"))

    quote = Quote.joins(:customer, :supplier)
      .where(customers: { name: "Fictora Consulting Group" })
      .where(suppliers: { name: "Good Energy" })
      .first

    assert_equal quote.rate, quote.normalized_rate
  end

  # -- idempotency and updates --

  test "re-importing same file is idempotent" do
    QuotesImporter.new.import_quotes(fixture_file("valid_quotes.csv"))
    QuotesImporter.new.import_quotes(fixture_file("valid_quotes.csv"))

    assert_equal 4, Quote.count
  end

  test "updates existing quotes with new values" do
    QuotesImporter.new.import_quotes(fixture_file("valid_quotes.csv"))
    QuotesImporter.new.import_quotes(fixture_file("updated_quotes.csv"))

    quote = Quote.joins(:customer, :supplier)
      .where(customers: { name: "Fictora Consulting Group" })
      .where(suppliers: { name: "Yukon Electric" })
      .first

    assert_equal false, quote.tax_included
    assert_in_delta 0.0750, quote.rate.to_f, 0.000001
  end

  # -- error handling --

  test "collects row-level errors and continues importing" do
    result = QuotesImporter.new.import_quotes(fixture_file("malformed_quotes.csv"))

    assert_not result.all_rows_imported?
    assert_equal 1, result.errors.size
    assert_match(/Row error/, result.errors.first)
    assert_equal 1, Quote.count
  end

  test "handles duplicate rows within file by keeping last" do
    QuotesImporter.new.import_quotes(fixture_file("duplicate_quotes.csv"))

    assert_equal 1, Quote.count
    assert_in_delta 0.0700, Quote.first.rate.to_f, 0.000001
  end

  # -- validation delegated to parser --

  test "raises for missing file" do
    assert_raises(ArgumentError) do
      QuotesImporter.new.import_quotes("/nonexistent/file.csv")
    end
  end

  test "raises for bad headers" do
    assert_raises(ArgumentError) do
      QuotesImporter.new.import_quotes(fixture_file("bad_headers.csv"))
    end
  end
end
