class AddImageDataToMaps < ActiveRecord::Migration[8.1]
  def change
    add_column :maps, :image_data, :binary
  end
end
