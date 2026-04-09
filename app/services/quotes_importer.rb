class QuotesImporter
  BATCH_SIZE = 1000
  COUNTRY_CODE = "US"

  def import_quotes(import_id)
    import = Import.find(import_id)
    import.update!(status: "processing")

    errors = []

    import.file.open do |tempfile|
      batch = []

      QuotesCsvParser.new.parse_csv(tempfile.path) do |row|
        if row[:error]
          errors << row[:error]
          next
        end

        batch << row[:attributes]

        if batch.size >= BATCH_SIZE
          upsert_batch(batch)
          batch = []
        end
      end

      upsert_batch(batch) if batch.any?
    end

    import.update!(status: "completed")
    Result.new(errors: errors)
  rescue ArgumentError => e
    import&.update!(status: "failed")
    Result.new(errors: [ e.message ])
  end

  private

  def upsert_batch(batch)
    resolved = batch.map { |attrs| resolve_row(attrs) }
    deduped = resolved.index_by { |r| [ r[:customer_id], r[:supplier_id] ] }.values

    Quote.upsert_all(
      deduped,
      unique_by: [ :customer_id, :supplier_id ],
      update_only: [ :rate, :tax_included, :normalized_rate ]
    )
  end

  def resolve_row(attrs)
    region = Region.find_or_create_by!(abbreviation: attrs[:state], country_code: COUNTRY_CODE) { |r|
      r.tax_rate = attrs[:tax_rate]
    }
    customer = Customer.find_or_create_by!(name: attrs[:customer_name]) { |c| c.region = region }
    supplier = Supplier.find_or_create_by!(name: attrs[:supplier_name])

    {
      customer_id: customer.id,
      supplier_id: supplier.id,
      rate: attrs[:rate],
      tax_included: attrs[:tax_included],
      normalized_rate: normalize_rate(attrs[:rate], attrs[:tax_included], attrs[:tax_rate])
    }
  end

  def normalize_rate(rate, tax_included, tax_rate)
    tax_included ? rate / (1 + tax_rate / 100) : rate
  end

  class Result
    attr_reader :errors

    def initialize(errors: [])
      @errors = errors
    end

    def all_rows_imported?
      errors.empty?
    end
  end
end
