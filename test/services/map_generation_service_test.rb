require "test_helper"
require "minitest/mock"

class MapGenerationServiceTest < ActiveSupport::TestCase
  setup do
    @map = maps(:muenster)
  end

  test "sets map to available with image_data on success" do
    fake_image = Vips::Image.black(100, 100)
    fake_png = fake_image.pngsave_buffer

    fake_fetcher = Object.new
    fake_fetcher.define_singleton_method(:fetch) { fake_image }

    fake_compositor = Object.new
    fake_compositor.define_singleton_method(:to_png) { fake_png }

    TileFetcher.stub(:new, fake_fetcher) do
      PosterCompositor.stub(:new, fake_compositor) do
        MapGenerationService.new(@map).call
      end
    end

    @map.reload
    assert @map.available?
    assert @map.image_data.present?
  end

  test "sets map to failed on error" do
    fake_fetcher = Object.new
    fake_fetcher.define_singleton_method(:fetch) { raise "tile error" }

    TileFetcher.stub(:new, fake_fetcher) do
      MapGenerationService.new(@map).call
    end

    @map.reload
    assert @map.failed?
  end
end
