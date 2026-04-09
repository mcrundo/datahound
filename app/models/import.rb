class Import < ApplicationRecord
  has_one_attached :file

  validates :file, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending processing completed failed] }
  validate :acceptable_file

  private

  def acceptable_file
    return unless file.attached?

    unless file.content_type == "text/csv"
      errors.add(:file, "must be a CSV file")
    end

    if file.byte_size > 500.megabytes
      errors.add(:file, "must be less than 500MB")
    end
  end
end
