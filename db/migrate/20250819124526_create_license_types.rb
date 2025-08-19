class CreateLicenseTypes < ActiveRecord::Migration[7.2]
  def change
    create_table :license_types do |t|
      t.string :name, null: false, index: { unique: true }
      t.string :display_name, null: false
      t.text :description
      t.integer :monthly_token_limit, null: false
      t.decimal :price_per_month, precision: 8, scale: 2, default: 0.0, null: false
      t.boolean :active, default: true, null: false
      t.integer :max_conversations_per_day, default: nil
      t.integer :max_iterations_per_conversation, default: nil
      t.jsonb :features, default: {}
      t.integer :sort_order, default: 0

      t.timestamps
    end

    add_index :license_types, :active
    add_index :license_types, :sort_order
  end
end
