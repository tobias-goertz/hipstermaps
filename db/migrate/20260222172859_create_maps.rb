class CreateMaps < ActiveRecord::Migration[8.1]
  def change
    create_table :maps do |t|
      t.string :format, null: false
      t.string :style, null: false
      t.float :lon, null: false
      t.float :lat, null: false
      t.float :zoom, null: false
      t.string :filename
      t.string :title, null: false
      t.string :subtitle
      t.string :coords
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
