#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'uri'

BASE_URL = 'http://localhost:3000'

def make_request(method, endpoint, body = nil, headers = {})
  uri = URI("#{BASE_URL}#{endpoint}")
  http = Net::HTTP.new(uri.host, uri.port)
  
  request = case method.upcase
  when 'POST'
    Net::HTTP::Post.new(uri)
  end
  
  request['Content-Type'] = 'application/json'
  headers.each { |key, value| request[key] = value }
  request.body = body.to_json if body
  
  response = http.request(request)
  
  puts "#{method} #{endpoint}"
  puts "Status: #{response.code} #{response.message}"
  puts "Response Headers:"
  response.each_header { |key, value| puts "  #{key}: #{value}" }
  puts "\nBody: #{response.body}"
  puts "=" * 50
  
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

puts "CHECKING RODAUTH JWT HEADERS"
puts "=" * 50

# Test Login and check headers for JWT token
login_response = make_request('POST', '/auth/login', {
  email: 'testdebug@example.com',
  password: 'testpassword123'
})

if login_response && login_response[:status] == 200
  puts "\nAnalyzing Response:"
  puts "- Status: #{login_response[:status]}"
  puts "- Body Keys: #{login_response[:body].keys}"
  
  # Check Authorization header specifically
  auth_header = login_response[:headers]['authorization']
  if auth_header
    puts "✅ FOUND JWT TOKEN IN AUTHORIZATION HEADER!"
    puts "Authorization: #{auth_header.first}"
  else
    puts "❌ No Authorization header found"
    puts "All headers: #{login_response[:headers].keys}"
  end
else
  puts "Login failed"
end
