class AddTimeagoToPost < ActiveRecord::Migration[6.1]
  def change
    add_column :posts, :time_ago, :Time
  end
end
