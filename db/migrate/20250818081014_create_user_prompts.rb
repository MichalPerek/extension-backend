class CreateUserPrompts < ActiveRecord::Migration[7.2]
  def change
    create_table :user_prompts do |t|
      t.references :account, null: false, foreign_key: true
      t.string :title, null: false, limit: 255
      t.text :content, null: false

      t.timestamps
    end

    add_index :user_prompts, [:account_id, :created_at], name: 'index_user_prompts_on_account_and_created_at'
  end
end
