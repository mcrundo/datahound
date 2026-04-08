class Region < ApplicationRecord
  has_many :customers, dependent: :restrict_with_exception

  validates :abbreviation, presence: true
  validates :country_code, presence: true, format: { with: /\A[A-Z]{2}\z/ }
  validates :tax_rate, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :abbreviation, uniqueness: { scope: :country_code, case_sensitive: false }
end
