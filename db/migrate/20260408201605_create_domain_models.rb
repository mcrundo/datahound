class CreateDomainModels < ActiveRecord::Migration[8.1]
  def change
    create_table :regions do |t|
      t.string :abbreviation, null: false
      t.string :country_code, null: false
      t.decimal :tax_rate, precision: 5, scale: 2, null: false

      t.timestamps
    end

    add_index :regions, [ :abbreviation, :country_code ], unique: true
    add_check_constraint :regions, "abbreviation <> ''", name: "regions_abbreviation_not_empty"
    add_check_constraint :regions, "country_code ~ '^[A-Z]{2}$'", name: "regions_country_code_format"
    add_check_constraint :regions, "tax_rate >= 0", name: "regions_tax_rate_non_negative"

    create_table :customers do |t|
      t.string :name, null: false
      t.references :region, null: false, foreign_key: true

      t.timestamps
    end

    add_index :customers, "lower(name)", unique: true, name: "index_customers_on_lower_name"
    add_check_constraint :customers, "name <> ''", name: "customers_name_not_empty"

    create_table :suppliers do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :suppliers, "lower(name)", unique: true, name: "index_suppliers_on_lower_name"
    add_check_constraint :suppliers, "name <> ''", name: "suppliers_name_not_empty"

    create_table :quotes do |t|
      t.references :customer, null: false, foreign_key: true
      t.references :supplier, null: false, foreign_key: true
      t.decimal :rate, precision: 8, scale: 6, null: false
      t.boolean :tax_included, null: false, default: false
      t.decimal :normalized_rate, precision: 8, scale: 6, null: false

      t.timestamps
    end

    add_index :quotes, [ :customer_id, :supplier_id ], unique: true
    add_check_constraint :quotes, "rate > 0", name: "quotes_rate_positive"
    add_check_constraint :quotes, "normalized_rate > 0", name: "quotes_normalized_rate_positive"
  end
end
