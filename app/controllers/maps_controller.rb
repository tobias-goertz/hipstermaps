class MapsController < ApplicationController
  def new
    @map = Map.new
    render :new
  end

  def create
    @map = Map.new(map_params)

    if @map.save
      redirect_to map_path(@map)
    else
      flash[:alert] = @map.errors.full_messages.to_sentence
      render :new
    end
  end

  def show
    @map = Map.find(params[:id])
    render :show
  end

  def status
    map = Map.find(params[:map_id])
    render plain: map.status
  end

  private

  def map_params
    params.require(:map).permit([:title, :format, :lon, :lat, :zoom, :style, :subtitle, :coords])
  end
end
