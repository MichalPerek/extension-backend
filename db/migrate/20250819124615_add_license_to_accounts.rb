class AddLicenseToAccounts < ActiveRecord::Migration[7.2]
  def change
    add_reference :accounts, :license_type, null: true, foreign_key: true
    add_column :accounts, :current_month_tokens_used, :integer, default: 0, null: false
    add_column :accounts, :user_month_start, :date, default: -> { 'CURRENT_DATE' }, null: false
    add_column :accounts, :license_expires_at, :datetime, default: nil
    add_column :accounts, :license_auto_renew, :boolean, default: true, null: false

    add_index :accounts, :current_month_tokens_used
    add_index :accounts, :license_expires_at
  end
end
