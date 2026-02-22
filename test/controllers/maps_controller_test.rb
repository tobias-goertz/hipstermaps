require "test_helper"

class MapsControllerTest < ActionDispatch::IntegrationTest
  test "GET / renders the new map form" do
    get root_path
    assert_response :success
    assert_select "form"
  end

  test "GET /maps/new renders the new map form" do
    get new_map_path
    assert_response :success
  end

  test "POST /maps with valid params creates a map and redirects" do
    assert_difference("Map.count", 1) do
      post maps_path, params: {
        map: {
          format: "2:3",
          style: "shigawire/cjkqod0by7xsc2rpju6kvos0x",
          lon: 7.617,
          lat: 51.960,
          zoom: 14.0,
          title: "MÜNSTER",
          subtitle: "GERMANY",
          coords: "51° 57' 36\" N - 7° 37' 1\" E"
        }
      }
    end

    assert_redirected_to map_path(Map.last)
  end

  test "POST /maps with invalid params re-renders the form" do
    assert_no_difference("Map.count") do
      post maps_path, params: {
        map: { format: "", style: "", lon: "", lat: "", zoom: "", title: "" }
      }
    end

    assert_response :unprocessable_entity
  end

  test "GET /maps/:id shows the map" do
    map = maps(:completed)
    get map_path(map)
    assert_response :success
    assert_select "h1", text: /BERLIN/
  end

  test "GET /maps/:id for in-progress map shows spinner" do
    map = maps(:muenster)
    get map_path(map)
    assert_response :success
    assert_select ".animate-spin"
  end

  test "GET /maps/:id for failed map shows error" do
    map = maps(:failed)
    get map_path(map)
    assert_response :success
    assert_match(/failed/i, response.body)
  end
end
