class AddTimestampsToAccounts < ActiveRecord::Migration[7.2]
  def change
    add_column :accounts, :created_at, :datetime, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    add_column :accounts, :updated_at, :datetime, null: false, default: -> { 'CURRENT_TIMESTAMP' }
  end
end
