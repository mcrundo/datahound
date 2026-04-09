class QuotesCsvParser
  EXPECTED_HEADERS = [ "Customer", "Supplier", "Quote", "Tax Included", "State", "Tax Rate" ].freeze

  def parse_csv(file_path)
    validate_file!(file_path)

    CSV.foreach(file_path, headers: true, header_converters: :symbol) do |row|
      next if row.to_h.values.all?(&:blank?)

      yield parse_row(row)
    end
  end

  private

  def validate_file!(file_path)
    raise ArgumentError, "File not found: #{file_path}" unless File.exist?(file_path)

    headers = CSV.open(file_path, &:readline)
    missing = EXPECTED_HEADERS - headers
    raise ArgumentError, "Missing CSV headers: #{missing.join(', ')}" if missing.any?
  end

  def parse_row(row)
    if row[:customer].blank? || row[:supplier].blank?
      return { error: row_error(row, "Missing required fields") }
    end

    rate = BigDecimal(row[:quote])
    tax_included = row[:tax_included] == "Y"
    tax_rate = BigDecimal(row[:tax_rate])

    {
      attributes: {
        customer_name: row[:customer],
        supplier_name: row[:supplier],
        state: row[:state],
        tax_rate: tax_rate,
        rate: rate,
        tax_included: tax_included
      }
    }
  rescue ArgumentError, TypeError => e
    { error: row_error(row, e.message) }
  end

  def row_error(row, message)
    "Row error (#{row[:customer]}/#{row[:supplier]}): #{message}"
  end
end
