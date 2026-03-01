require "net/http"

class TileFetcher
  TILE_SIZE = 1024 # tileSize (512) * scale (2x retina)
  API_BASE = "https://api.mapbox.com"

  def initialize(style:, lon:, lat:, zoom:, width:, height:)
    @style = style
    @lon = lon.to_f
    @lat = lat.to_f
    @zoom = zoom.to_f
    @width = width
    @height = height
    @sm = SphericalMercator.new(size: TILE_SIZE)
  end

  def fetch
    tiles = tile_list
    # White RGB canvas — tiles may have semi-transparent areas that must
    # blend over white (not black) to match the Mapbox rendering.
    white = (Vips::Image.black(tiles[:width], tiles[:height]) + 255).cast(:uchar)
    canvas = white.bandjoin([ white, white ])

    tiles[:entries].each do |tile|
      tile_image = fetch_tile(tile[:z], tile[:x], tile[:y])
      canvas = composite_tile(canvas, tile_image, tile[:px], tile[:py])
    end

    canvas
  end

  private

  # Port of abaculus.coordsFromCenter + abaculus.tileList
  def tile_list
    # coordsFromCenter: convert center lon/lat to pixel coords
    origin = @sm.px(@lon, @lat, @zoom)
    cx = origin[0]
    cy = origin[1]
    w = @width
    h = @height

    ts = TILE_SIZE

    center_col = cx.to_f / TILE_SIZE
    center_row = cy.to_f / TILE_SIZE

    # pointCoordinate: convert output image corner to tile coordinate
    tl_col = (center_col + (0 - w / 2.0) / ts).floor
    tl_row = (center_row + (0 - h / 2.0) / ts).floor
    br_col = (center_col + (w - w / 2.0) / ts).floor
    br_row = (center_row + (h - h / 2.0) / ts).floor

    max_tiles = (2**@zoom).to_i
    entries = []

    (tl_col..br_col).each do |col|
      (tl_row..br_row).each do |row|
        # coordinatePoint: convert tile coordinate back to pixel position
        px = (w / 2.0 + ts * (col - center_col)).round
        py = (h / 2.0 + ts * (row - center_row)).round

        # Wrap tiles with negative column coordinates
        wrapped_col = col % max_tiles
        wrapped_col += max_tiles if wrapped_col < 0

        next if row < 0 || row >= max_tiles

        entries << { z: @zoom.to_i, x: wrapped_col, y: row, px: px, py: py }
      end
    end

    { width: w, height: h, entries: entries }
  end

  def fetch_tile(z, x, y)
    token = ENV.fetch("MAPBOX_ACCESS_TOKEN")
    url = "#{API_BASE}/styles/v1/#{@style}/tiles/512/#{z}/#{x}/#{y}@2x?access_token=#{token}"

    response = Net::HTTP.get_response(URI(url))
    raise "Tile fetch failed: #{response.code} for #{z}/#{x}/#{y}" unless response.is_a?(Net::HTTPSuccess)

    Vips::Image.new_from_buffer(response.body, "")
  end

  # Composite a tile onto the canvas, handling edge clipping
  # (tiles can extend beyond the output bounds, px/py can be negative)
  def composite_tile(canvas, tile, px, py)
    tw = tile.width
    th = tile.height

    # Source crop offsets (for tiles that start before the canvas origin)
    src_x = px < 0 ? -px : 0
    src_y = py < 0 ? -py : 0

    # Destination position on canvas
    dst_x = [ px, 0 ].max
    dst_y = [ py, 0 ].max

    # Visible width/height after clipping
    visible_w = [ tw - src_x, canvas.width - dst_x ].min
    visible_h = [ th - src_y, canvas.height - dst_y ].min

    return canvas if visible_w <= 0 || visible_h <= 0

    cropped = tile.crop(src_x, src_y, visible_w, visible_h)

    # Flatten tile alpha over white to match Mapbox rendering, then
    # strip alpha so it matches the RGB canvas for insert.
    if cropped.has_alpha?
      cropped = cropped.flatten(background: [ 255, 255, 255 ])
    end

    # Ensure band count matches canvas
    if cropped.bands < canvas.bands
      cropped = cropped.bandjoin(255) while cropped.bands < canvas.bands
    elsif cropped.bands > canvas.bands
      cropped = cropped[0..canvas.bands - 1]
    end

    canvas.insert(cropped, dst_x, dst_y)
  end
end
