class ChangeDateInPost < ActiveRecord::Migration[6.1]
  def change
    change_column_default :Posts, :date, nil
    change_column_default :Posts, :time, nil
  end
end
