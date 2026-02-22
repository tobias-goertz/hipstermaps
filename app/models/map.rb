class Map < ApplicationRecord
  enum :status, { in_progress: 0, available: 1, failed: 2 }

  broadcasts_to ->(map) { map }, inserts_by: :replace

  validates :format, presence: true
  validates :lon, presence: true, numericality: true
  validates :lat, presence: true, numericality: true
  validates :zoom, presence: true, numericality: { greater_than: 1 }
  validates :style, presence: true
  validates :title, presence: true

  before_create :set_filename
  after_commit :start_worker, on: :create

  def cdn_url
    "https://#{ENV["MAPS_CDN_HOST"]}/#{filename}"
  end

  def preview_url
    "https://#{ENV["MAPS_CDN_HOST"]}/preview_#{filename}"
  end

  private

  def set_filename
    self.filename ||= "#{SecureRandom.urlsafe_base64}.png"
  end

  def start_worker
    MapGenerationJob.perform_later(id) if in_progress?
  end
end
