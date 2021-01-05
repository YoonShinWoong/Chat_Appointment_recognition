class ChangeTimeagoToBeDatetimeInPosts < ActiveRecord::Migration[6.1]
  def change
    change_column :posts, :time_ago, :datetime
  end
end
