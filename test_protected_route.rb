#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'uri'

BASE_URL = 'http://localhost:3000'

def make_request(method, endpoint, body = nil, headers = {})
  uri = URI("#{BASE_URL}#{endpoint}")
  http = Net::HTTP.new(uri.host, uri.port)
  
  request = case method.upcase
  when 'GET'
    Net::HTTP::Get.new(uri)
  when 'POST'
    Net::HTTP::Post.new(uri)
  end
  
  request['Content-Type'] = 'application/json'
  headers.each { |key, value| request[key] = value }
  request.body = body.to_json if body
  
  response = http.request(request)
  
  puts "#{method} #{endpoint}"
  puts "Status: #{response.code} #{response.message}"
  puts "Body: #{response.body}"
  puts "---"
  
  {
    status: response.code.to_i,
    body: response.body.empty? ? {} : JSON.parse(response.body),
    headers: response.to_hash
  }
rescue JSON::ParserError
  {
    status: response.code.to_i,
    body: response.body,
    headers: response.to_hash
  }
rescue => e
  puts "Error: #{e.message}"
  nil
end

puts "Testing Full Authentication Flow"
puts "=" * 40

# Step 1: Login to get JWT token
puts "1. Getting JWT token..."
login_response = make_request('POST', '/auth/login', {
  email: 'testdebug@example.com',
  password: 'testpassword123'
})

if login_response && login_response[:status] == 200
  puts "✅ Login successful"
  token = login_response[:body]['access_token']
  
  puts "\n" + "=" * 40
  
  # Step 2: Test protected route WITHOUT token
  puts "2. Testing protected route without token..."
  profile_response_no_token = make_request('GET', '/api/users/profile')
  
  if profile_response_no_token && profile_response_no_token[:status] == 401
    puts "✅ Route properly protected - unauthorized without token"
  else
    puts "❌ Route protection failed - should return 401"
  end
  
  puts "\n" + "=" * 40
  
  # Step 3: Test protected route WITH token
  puts "3. Testing protected route with valid JWT token..."
  profile_response = make_request('GET', '/api/users/profile', nil, {
    'Authorization' => "Bearer #{token}"
  })
  
  if profile_response && profile_response[:status] == 200
    puts "✅ Protected route access successful with JWT token"
    puts "Profile Data: #{profile_response[:body]['user']}"
  else
    puts "❌ Protected route access failed with token"
  end
  
else
  puts "❌ Login failed - cannot test protected routes"
end

puts "\n" + "=" * 40
puts "Authentication flow testing complete!"
