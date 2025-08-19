class CreateLlmModels < ActiveRecord::Migration[7.2]
  def change
    create_table :llm_models do |t|
      t.string :name, null: false
      t.string :provider, null: false
      t.string :model_id, null: false
      t.text :prompt, null: false
      t.jsonb :config, default: {}
      t.boolean :enabled, default: true

      t.timestamps
    end

    add_index :llm_models, :provider
    add_index :llm_models, :enabled
    add_index :llm_models, [:provider, :model_id], unique: true
  end
end
