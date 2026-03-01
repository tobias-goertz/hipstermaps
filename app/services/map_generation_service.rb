class MapGenerationService
  def initialize(map)
    @map = map
  end

  def call
    format_size = PosterCompositor::FORMAT_SIZES.fetch(@map.format)
    image_dims = format_size[:image]

    map_image = TileFetcher.new(
      style: @map.style,
      lon: @map.lon,
      lat: @map.lat,
      zoom: @map.zoom,
      width: image_dims[:w],
      height: image_dims[:h]
    ).fetch

    png_data = PosterCompositor.new(
      format: @map.format,
      map_image: map_image,
      title: @map.title,
      subtitle: @map.subtitle,
      coords: @map.coords
    ).to_png

    @map.update!(image_data: png_data, status: :available)
  rescue => e
    Rails.logger.error("Map generation failed for Map##{@map.id}: #{e.message}")
    @map.failed!
  end
end
