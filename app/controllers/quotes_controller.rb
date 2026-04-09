class QuotesController < ApplicationController
  def index
    @quotes = Quote.includes(:customer, :supplier).order(created_at: :desc)
    @import = Import.find_by(id: params[:import_id])
  end
end
