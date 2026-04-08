class Supplier < ApplicationRecord
  has_many :quotes, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
