# -*- coding="utf-8 -*-
# require 'bundler/setup'
# Bundler.require
# require 'yaml'
require 'net/http'
# require 'uri'
# require 'csv'
require 'JSON'


#  - - - - - - - - - - - - - - - - - - - - - - - - - - -

def Private_api(body)

	nonce = Time.now.to_i.to_s
	url = "https://coincheck.jp" + body
	uri = URI.parse url
	message = nonce + uri.to_s
	api_secret_key = ENV["CHECKCOIN-SECRET-KEY"]

	signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), api_secret_key, message)

	headers = {
		ENV["CHECKCOIN-ACCESS-KEY"] => api_key,
		"ACCESS-NONCE" => nonce,
		"ACCESS-SIGNATURE" => signature
	}

	https = Net::HTTP.new(uri.host, uri.port)
	https.use_ssl = true
	response = https.start { https.get(uri.request_uri, headers) }

	return JSON.parse(response.body)

end

#  - - - - - - - - - - - - - - - - - - - - - - - - - - -

def Public_api(body)

	url = "https://coincheck.jp" + body.to_s
	uri = URI.parse url
	https = Net::HTTP.new(uri.host, uri.port)
	https.use_ssl = true
	response = https.start { https.get(uri) }

	return JSON.parse(response.body)

end

#  - - - - - - - - - - - - - - - - - - - - - - - - - - -

def Count_trade(trades)

	buy = 0
	sell = 0
	total = trades.length

	for trade in trades
		if trade["order_type"] == "buy" then
			buy += 1 
			# trade["rate"].to_s + " : " +  trade["amount"].to_s
		elsif trade["order_type"] == "sell" then
			sell += 1
		end
	end

	return {"total"=> total, "buy"=> buy, "sell"=> sell }

end

#  - - - - - - - - - - - - - - - - - - - - - - - - - - -

def Get_valid_volume(order_books_resp)

	ask_volume = 0.to_f
	bid_volume = 0.to_f

	for ask in order_books_resp["asks"]
		if ask_volume < ask[1].to_f then
			ask_volume = ask[1].to_f
			ask_price = ask[0].to_f
			p ask_volume.to_s + " : " + ask_price.to_s
		end
	end

	for bid in order_books_resp["bids"]
		if bid_volume < bid[1].to_f then
			bid_volume = bid[1].to_f
			bid_price = bid[0].to_f
			p bid_volume.to_s + " : " + bid_price.to_s			
		end
	end	

	return {"ask_price"=> ask_price, "ask_volume"=> ask_volume, "bid_price"=> bid_price, "bid_volume"=> bid_volume}

end

#  - - - - - - - - - - - - - - - - - - - - - - - - - - -

# ticker_resp = Public_api("/api/ticker")
order_books_resp = Public_api("/api/order_books")
# trades_resp = Public_api("/api/trades")

# trades_count = Count_trade(trades_resp)

# p trades_resp
# p trades_count
valid_volume = Get_valid_volume(order_books_resp)
p valid_volume