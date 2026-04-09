class QuotesController < ApplicationController
  def index
    quotes = Quote.includes(customer: :region, supplier: {})
                  .by_region(params[:region])
                  .by_supplier(params[:supplier_id])
                  .by_tax_included(params[:tax_included])
                  .sorted_by(params[:sort])

    @pagy, @quotes = pagy(quotes, limit: 25)
    @import = Import.find_by(id: params[:import_id])
  end
end
