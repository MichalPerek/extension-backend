# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create default plans
plans_data = [
  {
    name: 'Free Plan',
    points: 10,
    description: 'Basic plan with limited points for casual users',
    active: true
  },
  {
    name: 'Pro Plan',
    points: 100,
    description: 'Professional plan with generous point allocation',
    active: true
  },
  {
    name: 'Enterprise Plan',
    points: 1000,
    description: 'Enterprise plan with maximum point allocation',
    active: true
  }
]

plans_data.each do |plan_data|
  Plan.find_or_create_by!(name: plan_data[:name]) do |plan|
    plan.points = plan_data[:points]
    plan.description = plan_data[:description]
    plan.active = plan_data[:active]
  end
end

puts "Created #{Plan.count} plans:"
Plan.all.each do |plan|
  puts "  - #{plan.name}: #{plan.points} points"
end
