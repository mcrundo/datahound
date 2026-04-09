class ImportQuotesJob < ApplicationJob
  queue_as :default

  discard_on ArgumentError do |job, error|
    Rails.logger.error("[ImportQuotesJob] Discarded (#{error.message}): #{job.arguments.first}")
  end

  retry_on ActiveRecord::Deadlocked, wait: :polynomially_longer, attempts: 3

  def perform(file_path)
    result = QuotesImporter.new.import_quotes(file_path)

    if result.all_rows_imported?
      Rails.logger.info("[ImportQuotesJob] Imported #{file_path} with no errors")
    else
      Rails.logger.warn("[ImportQuotesJob] Imported #{file_path} with #{result.errors.size} error(s): #{result.errors.join('; ')}")
    end
  end
end
