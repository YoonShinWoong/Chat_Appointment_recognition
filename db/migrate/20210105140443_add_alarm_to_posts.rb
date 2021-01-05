class AddAlarmToPosts < ActiveRecord::Migration[6.1]
  def change
    add_column :posts, :alarmstat, :string
  end
end
