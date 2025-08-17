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

# Test Login with existing account
puts "Testing login..."
login_response = make_request('POST', '/auth/login', {
  email: 'testdebug@example.com',
  password: 'testpassword123'
})

if login_response && login_response[:status] == 200
  puts "Login successful"
  response_body = login_response[:body]
  puts "Full response: #{response_body.inspect}"
  
  # Test if JWT token is present
  if response_body['access_token']
    puts "✅ JWT token found: #{response_body['access_token'][0..20]}..."
  else
    puts "❌ No JWT token in response"
  end
else
  puts "Login failed"
  puts "Status: #{login_response[:status] if login_response}"
  puts "Body: #{login_response[:body] if login_response}"
end

puts "\n" + "=" * 40

# Test Create Account with new user  
puts "Testing create account with new user..."
signup_response = make_request('POST', '/auth/create-account', {
  name: 'Test User Latest',
  email: "test#{Time.now.to_i}@example.com",
  password: 'testpassword123'
})

if signup_response && signup_response[:status] == 200
  puts "Create account successful"
  response_body = signup_response[:body]
  puts "Full response: #{response_body.inspect}"
  
  # Test if JWT token is present
  if response_body['access_token']
    puts "✅ JWT token found: #{response_body['access_token'][0..20]}..."
  else
    puts "❌ No JWT token in response"
  end
else
  puts "Create account failed"
  puts "Status: #{signup_response[:status] if signup_response}"
  puts "Body: #{signup_response[:body] if signup_response}"
end
