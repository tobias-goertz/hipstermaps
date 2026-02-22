require "test_helper"

class MapTest < ActiveSupport::TestCase
  def valid_attributes
    {
      format: "2:3",
      style: "shigawire/cjkqod0by7xsc2rpju6kvos0x",
      lon: 7.617,
      lat: 51.960,
      zoom: 14.0,
      title: "MÜNSTER",
      subtitle: "GERMANY",
      coords: "51° 57' 36\" N - 7° 37' 1\" E"
    }
  end

  test "valid map" do
    map = Map.new(valid_attributes)
    assert map.valid?
  end

  test "requires format" do
    map = Map.new(valid_attributes.except(:format))
    assert_not map.valid?
    assert_includes map.errors[:format], "can't be blank"
  end

  test "requires lon" do
    map = Map.new(valid_attributes.except(:lon))
    assert_not map.valid?
  end

  test "requires lat" do
    map = Map.new(valid_attributes.except(:lat))
    assert_not map.valid?
  end

  test "requires zoom greater than 1" do
    map = Map.new(valid_attributes.merge(zoom: 0.1))
    assert_not map.valid?
    assert_includes map.errors[:zoom], "must be greater than 1"
  end

  test "requires style" do
    map = Map.new(valid_attributes.except(:style))
    assert_not map.valid?
  end

  test "requires title" do
    map = Map.new(valid_attributes.except(:title))
    assert_not map.valid?
  end

  test "default status is in_progress" do
    map = Map.new(valid_attributes)
    assert_equal "in_progress", map.status
  end

  test "enum status values" do
    assert_equal 0, Map.statuses[:in_progress]
    assert_equal 1, Map.statuses[:available]
    assert_equal 2, Map.statuses[:failed]
  end
end
