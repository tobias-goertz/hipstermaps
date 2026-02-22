class MapGenerationJob < ApplicationJob
  queue_as :default

  def perform(map_id)
    map = Map.find(map_id)
    MapGenerationService.new(map).call
  end
end
