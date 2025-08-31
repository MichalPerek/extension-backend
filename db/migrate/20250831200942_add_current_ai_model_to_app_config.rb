class AddCurrentAiModelToAppConfig < ActiveRecord::Migration[7.2]
  def change
    add_reference :app_configs, :current_ai_model, null: true, foreign_key: { to_table: :llm_models }
  end
end
