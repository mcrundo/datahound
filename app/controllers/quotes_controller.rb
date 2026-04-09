class QuotesController < ApplicationController
  def index
    @pagy, @quotes = pagy(
      Quote.includes(customer: :region, supplier: {}).order(created_at: :desc),
      limit: 25
    )
    @import = Import.find_by(id: params[:import_id])
  end
end
