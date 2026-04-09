require "test_helper"

class QuoteTest < ActiveSupport::TestCase
  test "valid quote" do
    quote = Quote.new(
      customer: customers(:nullpoint),
      supplier: suppliers(:good_energy),
      rate: 0.0650,
      tax_included: false,
      normalized_rate: 0.0650
    )
    assert quote.valid?
  end

  test "requires rate" do
    quote = Quote.new(
      customer: customers(:nullpoint),
      supplier: suppliers(:good_energy),
      rate: nil,
      tax_included: false,
      normalized_rate: 0.0650
    )
    assert_not quote.valid?
  end

  test "rate must be positive" do
    quote = Quote.new(
      customer: customers(:nullpoint),
      supplier: suppliers(:good_energy),
      rate: 0,
      tax_included: false,
      normalized_rate: 0.0650
    )
    assert_not quote.valid?
  end

  test "normalized_rate must be positive" do
    quote = Quote.new(
      customer: customers(:nullpoint),
      supplier: suppliers(:good_energy),
      rate: nil,
      tax_included: false,
      normalized_rate: 0
    )
    quote.valid?
    assert_includes quote.errors.attribute_names, :normalized_rate
  end

  test "customer and supplier pair must be unique" do
    existing = quotes(:fictora_yukon)
    duplicate = Quote.new(
      customer: existing.customer,
      supplier: existing.supplier,
      rate: 0.0700,
      tax_included: false,
      normalized_rate: 0.0700
    )
    assert_not duplicate.valid?
  end

  test "same supplier can quote different customers" do
    quote = Quote.new(
      customer: customers(:nullpoint),
      supplier: suppliers(:yukon),
      rate: 0.0550,
      tax_included: false,
      normalized_rate: 0.0550
    )
    assert quote.valid?
  end

  test "belongs to customer" do
    assert_equal customers(:fictora), quotes(:fictora_yukon).customer
  end

  test "belongs to supplier" do
    assert_equal suppliers(:yukon), quotes(:fictora_yukon).supplier
  end
end
