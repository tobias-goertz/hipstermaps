require "test_helper"

class MapGenerationServiceTest < ActiveSupport::TestCase
  setup do
    @map = Map.new(
      id: 1,
      format: "2:3",
      style: "shigawire/cjkqod0by7xsc2rpju6kvos0x",
      lon: 7.617,
      lat: 51.960,
      zoom: 14.0,
      title: "MÜNSTER",
      subtitle: "GERMANY",
      coords: "51° 57' 36\" N - 7° 37' 1\" E",
      filename: "test123.png"
    )
  end

  test "builds correct lambda payload" do
    service = MapGenerationService.new(@map)
    payload = service.send(:lambda_payload)

    assert_equal "2:3", payload[:formatSize]
    assert_equal "shigawire/cjkqod0by7xsc2rpju6kvos0x", payload[:mapStyle]
    assert_equal 7.617, payload[:lon]
    assert_equal 51.960, payload[:lat]
    assert_equal 14.0, payload[:zoom]
    assert_equal "test123.png", payload[:bucketFile]
    assert_equal "MÜNSTER", payload[:title]
    assert_equal "GERMANY", payload[:subtitle]
  end
end
