class QuotesController < ApplicationController
  def index
    @quotes = Quote.includes(:customer, :supplier).order(created_at: :desc)
  end
end
