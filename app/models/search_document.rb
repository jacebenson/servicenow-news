class SearchDocument < ApplicationRecord
  TYPES = {
    "news" => "News",
    "partner" => "Partners",
    "application" => "Applications",
    "financial" => "Financials",
    "event" => "Events",
    "mvp" => "MVPs"
  }.freeze

  validates :record_type, :record_id, :title, :local_path, :destination_label, presence: true
  validates :record_id, uniqueness: { scope: :record_type }

  scope :of_type, ->(type) { where(record_type: type) }

  def type_label
    TYPES.fetch(record_type, record_type.humanize)
  end
end
