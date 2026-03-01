class Map < ApplicationRecord
  enum :status, { in_progress: 0, available: 1, failed: 2 }

  broadcasts_to ->(map) { map }, inserts_by: :replace

  validates :format, presence: true
  validates :lon, presence: true, numericality: true
  validates :lat, presence: true, numericality: true
  validates :zoom, presence: true, numericality: { greater_than: 1 }
  validates :style, presence: true
  validates :title, presence: true

  after_commit :start_worker, on: :create

  def image_url
    Rails.application.routes.url_helpers.image_map_path(self)
  end

  private

  def start_worker
    MapGenerationJob.perform_later(id) if in_progress?
  end
end
