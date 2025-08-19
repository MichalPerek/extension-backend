class CreateAppConfig < ActiveRecord::Migration[7.2]
  def change
    create_table :app_configs do |t|
      t.integer :max_iterations, null: false, default: 10
      t.integer :max_original_text_length, null: false, default: 10_000
      t.integer :max_result_text_length, null: false, default: 50_000
      t.integer :max_instruction_length, null: false, default: 2_000
      t.bigint :global_monthly_token_limit, null: false, default: 10_000_000
      t.bigint :global_current_month_tokens_used, null: false, default: 0
      t.decimal :token_price_usd, precision: 10, scale: 6, null: false, default: 0.000002
      t.date :global_month_start, null: false
      t.integer :estimated_tokens_per_call, null: false, default: 500

      t.timestamps
    end
  end
end
