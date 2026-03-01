class PosterCompositor
  FORMAT_SIZES = {
    "2:3" => {
      image: { w: 5400, h: 6900 },
      poster: {
        w: 5906, h: 8858, offset: 253,
        font_size1: 350, font_size2: 250, font_size3: 190,
        stroke: 30, letter_spacing: 75
      }
    },
    "3:4" => {
      image: { w: 3243, h: 3580 },
      poster: {
        w: 3543, h: 4724, offset: 150,
        font_size1: 250, font_size2: 150, font_size3: 120,
        stroke: 20, letter_spacing: 50
      }
    }
  }.freeze

  def initialize(format:, map_image:, title:, subtitle:, coords:)
    @format_size = FORMAT_SIZES.fetch(format)
    @map_image = map_image
    @title = title
    @subtitle = subtitle
    @coords = coords
  end

  def to_png
    poster = @format_size[:poster]
    w = poster[:w]
    h = poster[:h]

    svg = build_svg(w, h, poster)
    frame = Vips::Image.svgload_buffer(svg)

    # Ensure map image is same band format as frame
    map = @map_image
    if map.bands < frame.bands
      map = map.bandjoin(255) while map.bands < frame.bands
    elsif map.bands > frame.bands
      map = map.flatten
    end

    poster_image = frame.insert(map, poster[:offset], poster[:offset])
    poster_image.pngsave_buffer
  end

  private

  def build_svg(w, h, poster)
    title = escape_xml(@title || "")
    subtitle = escape_xml(@subtitle || "")
    coords = escape_xml(@coords || "")

    <<~SVG
      <svg width="#{w}" height="#{h}" viewBox="0 0 #{w} #{h}" xmlns="http://www.w3.org/2000/svg">
      <rect width="100%" height="100%" fill="#fff" />
      <text
        x="#{w / 2}"
        y="#{(h * 0.865).round}"
        font-size="#{poster[:font_size1]}"
        fill="#2d6886"
        font-weight="bold"
        text-anchor="middle"
        font-family="sans-serif"
        letter-spacing="#{poster[:letter_spacing]}">
        #{title}
      </text>
      <line
        x1="#{((w / 2.0) * 0.66).round}"
        y1="#{(h * 0.88).round}"
        x2="#{((w / 2.0) * 1.33).round}"
        y2="#{(h * 0.88).round}"
        style="stroke:rgb(0,0,0);stroke-width:#{poster[:stroke]}" />
      <text
        x="#{w / 2}"
        y="#{(h * 0.92).round}"
        font-size="#{poster[:font_size2]}"
        fill="#2d6886"
        text-anchor="middle"
        font-family="sans-serif"
        letter-spacing="#{poster[:letter_spacing]}">
        #{subtitle}
      </text>
      <text
        x="#{w / 2}"
        y="#{(h * 0.96).round}"
        font-size="#{poster[:font_size3]}"
        font-style="italic"
        fill="#2d6886"
        text-anchor="middle"
        font-family="sans-serif">
        #{coords}
      </text>
      </svg>
    SVG
  end

  def escape_xml(text)
    text.to_s
      .gsub("&", "&amp;")
      .gsub("<", "&lt;")
      .gsub(">", "&gt;")
      .gsub("'", "&apos;")
      .gsub('"', "&quot;")
  end
end
