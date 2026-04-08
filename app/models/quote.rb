class Quote < ApplicationRecord
  belongs_to :customer
  belongs_to :supplier

  validates :rate, presence: true, numericality: { greater_than: 0 }
  validates :normalized_rate, presence: true, numericality: { greater_than: 0 }
  validates :tax_included, inclusion: { in: [ true, false ] }
  validates :supplier_id, uniqueness: { scope: :customer_id }
end
