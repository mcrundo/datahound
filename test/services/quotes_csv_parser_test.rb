require "test_helper"

class QuotesCsvParserTest < ActiveSupport::TestCase
  def fixture_file(name)
    Rails.root.join("test/fixtures/files/#{name}")
  end

  def collect_rows(file)
    rows = []
    QuotesCsvParser.new.parse_csv(fixture_file(file)) { |row| rows << row }
    rows
  end

  # -- valid parsing --

  test "parses all data rows from valid CSV" do
    rows = collect_rows("valid_quotes.csv")

    assert_equal 4, rows.size
    assert rows.all? { |r| r[:attributes].present? }
  end

  test "returns expected attributes for a parsed row" do
    attrs = collect_rows("valid_quotes.csv").first[:attributes]

    assert_equal "Fictora Consulting Group", attrs[:customer_name]
    assert_equal "Yukon Electric", attrs[:supplier_name]
    assert_equal "MA", attrs[:state]
    assert_equal BigDecimal("0.0662"), attrs[:rate]
    assert_equal BigDecimal("7.5"), attrs[:tax_rate]
    assert_equal true, attrs[:tax_included]
  end

  test "does not include normalized_rate in parsed attributes" do
    attrs = collect_rows("valid_quotes.csv").first[:attributes]

    assert_not_includes attrs.keys, :normalized_rate
  end

  # -- error handling --

  test "returns error hash for malformed rows" do
    rows = collect_rows("malformed_quotes.csv")
    errors = rows.select { |r| r[:error] }

    assert_equal 1, errors.size
    assert_match(/Row error/, errors.first[:error])
  end

  test "continues parsing after malformed row" do
    rows = collect_rows("malformed_quotes.csv")
    valid = rows.select { |r| r[:attributes] }

    assert_equal 1, valid.size
  end

  # -- file validation --

  test "raises for missing file" do
    assert_raises(ArgumentError) do
      QuotesCsvParser.new.parse_csv("/nonexistent/file.csv") { }
    end
  end

  test "raises for bad headers" do
    assert_raises(ArgumentError) do
      QuotesCsvParser.new.parse_csv(fixture_file("bad_headers.csv")) { }
    end
  end
end
