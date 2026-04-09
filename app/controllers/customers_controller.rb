class CustomersController < ApplicationController
  def index
    @customers = Customer.includes(:region)
                         .joins(:quotes)
                         .select(
                           "customers.*",
                           "COUNT(quotes.id) AS quotes_count",
                           "MIN(quotes.normalized_rate) AS best_rate",
                           "AVG(quotes.normalized_rate) AS avg_rate",
                           "MAX(quotes.normalized_rate) - MIN(quotes.normalized_rate) AS rate_spread"
                         )
                         .group("customers.id")
                         .order("customers.name ASC")

    best_quote_ids = Quote.select("DISTINCT ON (customer_id) id")
                          .order(:customer_id, normalized_rate: :asc)
    @best_quotes = Quote.where(id: best_quote_ids).includes(:supplier).index_by(&:customer_id)
  end
end
