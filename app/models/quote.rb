class Quote < ApplicationRecord
  belongs_to :customer
  belongs_to :supplier

  validates :rate, presence: true, numericality: { greater_than: 0 }
  validates :normalized_rate, presence: true, numericality: { greater_than: 0 }
  validates :tax_included, inclusion: { in: [ true, false ] }
  validates :supplier_id, uniqueness: { scope: :customer_id }

  scope :by_region, ->(abbreviation) { joins(customer: :region).where(regions: { abbreviation: abbreviation }) if abbreviation.present? }
  scope :by_supplier, ->(supplier_id) { where(supplier_id: supplier_id) if supplier_id.present? }
  scope :by_tax_included, ->(value) { where(tax_included: value == "true") if value.present? }

  SORT_OPTIONS = {
    "rate_asc" => { rate: :asc },
    "rate_desc" => { rate: :desc },
    "normalized_rate_asc" => { normalized_rate: :asc },
    "normalized_rate_desc" => { normalized_rate: :desc },
    "customer_asc" => Customer.arel_table[:name].asc,
    "customer_desc" => Customer.arel_table[:name].desc,
    "supplier_asc" => Supplier.arel_table[:name].asc,
    "supplier_desc" => Supplier.arel_table[:name].desc
  }.freeze

  scope :sorted_by, ->(key) { order(SORT_OPTIONS.fetch(key, { created_at: :desc })) }
end
