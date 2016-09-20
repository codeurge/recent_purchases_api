require 'bundler'
Bundler.require

redis = Redis.new
set :port, 3000
#EXT_API_URL = "http://localhost:8000/api"
EXT_API_URL = "http://74.50.59.155:6000/api"

get '/api/recent_purchases/:username' do
  content_type :json
  return redis[params[:username]] if redis[params[:username]]

  # fetch 5 recent purchases for the user: GET /api/purchases/by_user/:username?limit=5
  purchases = JSON.parse(
    HTTParty.get("#{EXT_API_URL}/purchases/by_user/#{params[:username]}?limit=5").body
  )['purchases']

  if purchases.count > 0
    output = purchases.map do |p|
      productId = p['productId']
      # for each of those products, get a list of all people who previously purchased that product: GET /api/purchases/by_product/:product_id
      users = JSON.parse(HTTParty.get("#{EXT_API_URL}/purchases/by_product/#{productId}").body)['purchases']
      # at the same time, request info about the products: GET /api/products/:product_id
      product = JSON.parse(HTTParty.get("#{EXT_API_URL}/products/#{productId}").body)['product']
      product['recent'] = users
      product
    end

    # finally, put all of the data together and sort it so that the product with the highest number of recent purchases is first.
    output.sort!{ |a,b| a['recent'].count <=> b['recent'].count }.reverse.to_json
    redis[params[:username]] = output
    output
  else
    "User with username of '#{params[:username]}' was not found".to_json
  end
end
