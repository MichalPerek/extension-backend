# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create default app configuration
AppConfig.first_or_create! do |config|
  config.global_month_start = Date.current.beginning_of_month
end

# Create license types
LicenseType.seed_builtin_licenses!

# Load LLM models
load Rails.root.join('db', 'seeds', 'llm_models.rb')

puts "✅ App configuration and license types initialized"
puts "Available license types:"
LicenseType.active.ordered.each do |license|
  puts "  - #{license.display_name}: #{license.monthly_token_limit} tokens/month"
end
