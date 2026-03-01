class MapsController < ApplicationController
  def new
    @map = Map.new
  end

  def create
    @map = Map.new(map_params)

    if @map.save
      redirect_to map_path(@map)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @map = Map.find(params[:id])
  end

  def image
    @map = Map.find(params[:id])

    if @map.available? && @map.image_data.present?
      send_data @map.image_data,
        type: "image/png",
        disposition: "inline",
        filename: "#{@map.title.parameterize}-poster.png"
      expires_in 1.year, public: true
    else
      head :not_found
    end
  end

  private

  def map_params
    params.expect(map: [ :title, :format, :lon, :lat, :zoom, :style, :subtitle, :coords ])
  end
end
