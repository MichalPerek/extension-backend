# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create a test user
user = User.create!(
  name: "Test User",
  email: "test@example.com",
  password: "password123"
)

puts "Created user: #{user.email}"

# Create a sample conversation
conversation = user.conversations.create!(
  original_text: "This is a sample conversation",
  final_text: "Processed: 'This is a sample conversation' - This is a mock response."
)

puts "Created conversation: #{conversation.id}"
