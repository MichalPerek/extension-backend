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

puts "Testing PROPER Rodauth JWT Implementation"
puts "=" * 50

# Test Login
puts "1. Testing LOGIN with Rodauth JWT..."
login_response = make_request('POST', '/auth/login', {
  email: 'testdebug@example.com',
  password: 'testpassword123'
})

if login_response && login_response[:status] == 200
  puts "✅ Login successful"
  
  # Check if Rodauth automatically generated JWT token
  if login_response[:body]['access_token']
    puts "✅ RODAUTH AUTOMATICALLY GENERATED JWT TOKEN!"
    puts "Token: #{login_response[:body]['access_token'][0..30]}..."
    
    # Check user profile data
    if login_response[:body]['user']
      puts "✅ User profile data included: #{login_response[:body]['user']['name']} (#{login_response[:body]['user']['email']})"
    else
      puts "❌ User profile data missing"
    end
    
  else
    puts "❌ No JWT token in response - Rodauth JWT not working properly"
    puts "Response keys: #{login_response[:body].keys}"
  end
  
else
  puts "❌ Login failed"
end

puts "\n" + "=" * 50

# Test Create Account
puts "2. Testing CREATE ACCOUNT with Rodauth JWT..."
signup_response = make_request('POST', '/auth/create-account', {
  name: 'Rodauth Test User',
  email: "rodauth_test_#{Time.now.to_i}@example.com",
  password: 'testpassword123'
})

if signup_response && signup_response[:status] == 200
  puts "✅ Account creation successful"
  
  # Check if Rodauth automatically generated JWT token
  if signup_response[:body]['access_token']
    puts "✅ RODAUTH AUTOMATICALLY GENERATED JWT TOKEN ON SIGNUP!"
    puts "Token: #{signup_response[:body]['access_token'][0..30]}..."
    
    # Check user profile data
    if signup_response[:body]['user']
      puts "✅ User profile data included: #{signup_response[:body]['user']['name']} (#{signup_response[:body]['user']['email']})"
    else
      puts "❌ User profile data missing"
    end
    
  else
    puts "❌ No JWT token in response - Rodauth JWT not working properly"
    puts "Response keys: #{signup_response[:body].keys}"
  end
  
else
  puts "❌ Account creation failed"
  puts "Status: #{signup_response[:status] if signup_response}"
  puts "Body: #{signup_response[:body] if signup_response}"
end

puts "\n" + "=" * 50
puts "Test complete!"
puts ""
puts "This is how Rodauth SHOULD work:"
puts "- ✅ JWT tokens generated automatically by Rodauth"
puts "- ✅ No manual token generation required" 
puts "- ✅ Proper use of authentication gem"
puts "- ✅ Clean, maintainable code"
