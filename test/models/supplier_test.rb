require "test_helper"

class SupplierTest < ActiveSupport::TestCase
  test "valid supplier" do
    supplier = Supplier.new(name: "New Supplier")
    assert supplier.valid?
  end

  test "requires name" do
    supplier = Supplier.new(name: "")
    assert_not supplier.valid?
  end

  test "name must be unique case-insensitively" do
    suppliers(:yukon) # "Yukon Electric" exists
    duplicate = Supplier.new(name: "yukon electric")
    assert_not duplicate.valid?
  end

  test "has many quotes" do
    supplier = suppliers(:yukon)
    assert_includes supplier.quotes, quotes(:fictora_yukon)
  end
end
