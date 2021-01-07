require 'net/https'
require 'uri'
require 'json'

# Get your Up token here: https://api.up.com.au/
token = "your_bearer_token_here"
# Find your SAVER account id using the following endpoint: https://developer.up.com.au/#get_accounts
account_id = "your_account_id_here"
# The maximum page size is 100, feel free to adjust
pagesize = "100"

def get_round_ups(token,pagesize,account_id)
  round_total = 0
  uri = URI.parse("https://api.up.com.au/api/v1/accounts/" + account_id + "/transactions?page[size]=" + pagesize)
  user_fields = http_req(uri,token,pagesize,account_id)
  total = rounder(user_fields, round_total)
  until user_fields['links']['next'].nil?
      uri = URI.parse(user_fields['links']['next'])
      user_fields = http_req(uri,token,pagesize,account_id)
      total += rounder(user_fields, round_total)
  end
	return total
end

def http_req(uri,token,pagesize,account_id)  
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new(uri.request_uri)
  request['Authorization'] = token
  response = http.request(request)
  user_fields = JSON.parse response.read_body
  return user_fields
end

def rounder(data_hash, round_total)
	data_hash['data'].each_with_index do |n,i|
      id_val = n['attributes']['description'].to_s
      if id_val == "Round Up"    
          round_amnt = n['attributes']['amount']['valueInBaseUnits'].to_i
          round_total += round_amnt
      end
  end
  return round_total
end

total_round_ups = get_round_ups(token,pagesize,account_id).to_f/100
puts "Total Round Ups: $" + total_round_ups.to_s
