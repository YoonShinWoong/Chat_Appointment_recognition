class CreateLotaddresses < ActiveRecord::Migration[6.1]
  def change
    create_table :lotaddresses do |t|
      t.string :city
      t.string :ku
      t.string :dong
      t.string :lot

      t.timestamps
    end
  end
end
