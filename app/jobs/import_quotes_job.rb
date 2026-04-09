class ImportQuotesJob < ApplicationJob
  queue_as :default

  discard_on ActiveRecord::RecordNotFound
  retry_on ActiveRecord::Deadlocked, wait: :polynomially_longer, attempts: 3

  def perform(import_id)
    QuotesImporter.new.import_quotes(import_id)
  end
end
