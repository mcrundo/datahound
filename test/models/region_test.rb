require "test_helper"

class RegionTest < ActiveSupport::TestCase
  test "valid region" do
    region = Region.new(abbreviation: "NJ", country_code: "US", tax_rate: 7.0)
    assert region.valid?
  end

  test "requires abbreviation" do
    region = Region.new(abbreviation: "", country_code: "US", tax_rate: 7.0)
    assert_not region.valid?
  end

  test "requires country_code" do
    region = Region.new(abbreviation: "NJ", country_code: "", tax_rate: 7.0)
    assert_not region.valid?
  end

  test "country_code must be two uppercase letters" do
    assert_not Region.new(abbreviation: "NJ", country_code: "us", tax_rate: 7.0).valid?
    assert_not Region.new(abbreviation: "NJ", country_code: "USA", tax_rate: 7.0).valid?
    assert Region.new(abbreviation: "NJ", country_code: "US", tax_rate: 7.0).valid?
  end

  test "tax_rate cannot be negative" do
    region = Region.new(abbreviation: "NJ", country_code: "US", tax_rate: -1)
    assert_not region.valid?
  end

  test "tax_rate can be zero" do
    region = Region.new(abbreviation: "OR", country_code: "US", tax_rate: 0)
    assert region.valid?
  end

  test "abbreviation must be unique within country" do
    regions(:massachusetts) # MA, US exists
    duplicate = Region.new(abbreviation: "MA", country_code: "US", tax_rate: 5.0)
    assert_not duplicate.valid?
  end

  test "same abbreviation allowed in different countries" do
    regions(:massachusetts) # MA, US exists
    different_country = Region.new(abbreviation: "MA", country_code: "CA", tax_rate: 5.0)
    assert different_country.valid?
  end

  test "has many customers" do
    region = regions(:massachusetts)
    assert_includes region.customers, customers(:fictora)
  end
end
