class AddPointsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :initial_points, :integer, default: 0, null: false
    add_column :users, :remaining_points, :integer, default: 0, null: false
    
    add_index :users, :remaining_points
  end
end
