class Import < ApplicationRecord
  has_one_attached :file

  enum :status, { pending: "pending", processing: "processing", completed: "completed", failed: "failed" }, validate: true

  validates :file, presence: true
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
