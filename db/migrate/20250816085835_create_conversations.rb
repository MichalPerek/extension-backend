class CreateConversations < ActiveRecord::Migration[7.2]
  def change
    create_table :conversations do |t|
      t.references :user, null: false, foreign_key: true
      t.text :original_text, null: false
      t.jsonb :conversation_steps, default: [], null: false
      t.text :final_text
      t.integer :status, default: 0, null: false
      t.jsonb :metadata, default: {}

      t.timestamps
    end
    
    add_index :conversations, [:user_id, :created_at]
    add_index :conversations, :status
  end
end
