class CreatePlans < ActiveRecord::Migration[7.2]
  def change
    create_table :plans do |t|
      t.string :name, null: false
      t.integer :points, null: false, default: 0
      t.text :description
      t.boolean :active, default: true, null: false

      t.timestamps
    end
    
    add_index :plans, :name, unique: true
    add_index :plans, :active
  end
end
