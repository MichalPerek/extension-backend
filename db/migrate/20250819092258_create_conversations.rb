class CreateConversations < ActiveRecord::Migration[7.2]
  def change
    create_table :conversations do |t|
      t.references :account, null: false, foreign_key: true
      t.text :original_text, null: false
      t.jsonb :iterations, null: false, default: []
      t.integer :status, default: 0, null: false # 0: active, 1: completed, 2: archived
      t.string :session_id # For grouping related conversations

      t.timestamps
    end

    add_index :conversations, [:account_id, :created_at]
    add_index :conversations, :session_id
    add_index :conversations, :status
    add_index :conversations, :iterations, using: :gin
  end
end
