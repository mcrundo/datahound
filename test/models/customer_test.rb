require "test_helper"

class CustomerTest < ActiveSupport::TestCase
  test "valid customer" do
    customer = Customer.new(name: "New Customer", region: regions(:massachusetts))
    assert customer.valid?
  end

  test "requires name" do
    customer = Customer.new(name: "", region: regions(:massachusetts))
    assert_not customer.valid?
  end

  test "requires region" do
    customer = Customer.new(name: "New Customer", region: nil)
    assert_not customer.valid?
  end

  test "name must be unique case-insensitively" do
    customers(:fictora) # "Fictora Consulting Group" exists
    duplicate = Customer.new(name: "fictora consulting group", region: regions(:texas))
    assert_not duplicate.valid?
  end

  test "has many quotes" do
    customer = customers(:fictora)
    assert_includes customer.quotes, quotes(:fictora_yukon)
  end

  test "belongs to region" do
    customer = customers(:fictora)
    assert_equal regions(:massachusetts), customer.region
  end
end
