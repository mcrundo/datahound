class QuotesImporter
  BATCH_SIZE = 1000
  COUNTRY_CODE = "US"

  def import_quotes(import_id)
    import = Import.find(import_id)
    import.update!(status: "processing")
    broadcast_status(import, "processing", rows_processed: 0)

    errors = []
    rows_processed = 0

    import.file.open do |tempfile|
      batch = []

      QuotesCsvParser.new.parse_csv(tempfile.path) do |row|
        if row[:error]
          errors << row[:error]
          rows_processed += 1
          next
        end

        batch << row[:attributes]

        if batch.size >= BATCH_SIZE
          upsert_batch(batch)
          rows_processed += batch.size
          broadcast_status(import, "processing", rows_processed: rows_processed)
          batch = []
        end
      end

      if batch.any?
        upsert_batch(batch)
        rows_processed += batch.size
      end
    end

    import.update!(status: "completed")
    broadcast_status(import, "completed", rows_processed: rows_processed, error_count: errors.size)
    broadcast_quotes_list(import)
    Result.new(errors: errors)
  rescue ArgumentError => e
    import&.update!(status: "failed")
    broadcast_status(import, "failed") if import
    Result.new(errors: [ e.message ])
  end

  private

  def broadcast_quotes_list(import)
    quotes = Quote.includes(:customer, :supplier).order(created_at: :desc)
    Turbo::StreamsChannel.broadcast_replace_to(
      import,
      target: "quotes_list",
      partial: "quotes/list",
      locals: { quotes: quotes }
    )
  end

  def broadcast_status(import, status, rows_processed: 0, error_count: 0)
    Turbo::StreamsChannel.broadcast_replace_to(
      import,
      target: "import_#{import.id}_status",
      partial: "imports/status",
      locals: { import: import, status: status, rows_processed: rows_processed, error_count: error_count }
    )
  end

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
