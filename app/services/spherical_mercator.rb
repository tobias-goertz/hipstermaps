class SphericalMercator
  D2R = Math::PI / 180.0

  def initialize(size: 256)
    @size = size
    @bc = []
    @cc = []
    @zc = []
    @ac = []

    s = size
    30.times do
      @bc << s / 360.0
      @cc << s / (2.0 * Math::PI)
      @zc << s / 2.0
      @ac << s
      s *= 2
    end
  end

  # Convert [lon, lat] to pixel [x, y] at given zoom.
  # For float zoom, computes from scratch (no rounding).
  # For integer zoom, uses precached values and rounds.
  def px(lon, lat, zoom)
    f = [ [ Math.sin(D2R * lat), -0.9999 ].max, 0.9999 ].min

    if zoom % 1 != 0
      size = @size * (2**zoom)
      d = size / 2.0
      bc = size / 360.0
      cc = size / (2.0 * Math::PI)
      ac = size
      x = d + lon * bc
      y = d + 0.5 * Math.log((1 + f) / (1 - f)) * -cc
      x = ac if x > ac
      y = ac if y > ac
      [ x, y ]
    else
      z = zoom.to_i
      d = @zc[z]
      x = (d + lon * @bc[z]).round
      y = (d + 0.5 * Math.log((1 + f) / (1 - f)) * (-@cc[z])).round
      x = @ac[z] if x > @ac[z]
      y = @ac[z] if y > @ac[z]
      [ x, y ]
    end
  end
end
