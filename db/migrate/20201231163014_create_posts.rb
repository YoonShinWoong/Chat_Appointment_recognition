class CreatePosts < ActiveRecord::Migration[6.1]
  def change
    create_table :posts do |t|
      t.string :partner
      t.string :address
      t.string :phone
      t.date :date
      t.time :time

      t.timestamps
    end
  end
end
