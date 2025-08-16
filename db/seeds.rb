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

# Create default users with roles
users_data = [
  {
    name: 'Admin User',
    email: 'admin@example.com',
    role: 'admin',
    provider: 'email',
    uid: 'admin@example.com',
    initial_points: 1000,
    remaining_points: 1000
  },
  {
    name: 'Standard User',
    email: 'user@example.com',
    role: 'standard',
    provider: 'email',
    uid: 'user@example.com',
    initial_points: 100,
    remaining_points: 100
  }
]

users_data.each do |user_data|
  User.find_or_create_by!(email: user_data[:email]) do |user|
    user.name = user_data[:name]
    user.role = user_data[:role]
    user.provider = user_data[:provider]
    user.uid = user_data[:uid]
    user.initial_points = user_data[:initial_points]
    user.remaining_points = user_data[:remaining_points]
  end
end

puts "\nCreated #{User.count} users:"
User.all.each do |user|
  puts "  - #{user.name} (#{user.email}): #{user.role} role"
end
