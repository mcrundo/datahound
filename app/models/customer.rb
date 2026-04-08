class Customer < ApplicationRecord
  belongs_to :region
  has_many :quotes, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
