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

  private

  def map_params
    params.expect(map: [ :title, :format, :lon, :lat, :zoom, :style, :subtitle, :coords ])
  end
end
