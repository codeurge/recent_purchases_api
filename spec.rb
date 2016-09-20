require File.join(File.expand_path(File.dirname(__FILE__)), './', 'app')
require 'rspec'
require 'rack/test'

redis = Redis.new

describe 'Recent Purchases API' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it 'responds with username not found if it does not exist' do
    get '/api/recent_purchases/somethingFake'
    expect(last_response.body).to eq("User with username of 'somethingFake' was not found".to_json)
  end

  it 'responds with products sorted by recent purchases count' do
    user = JSON.parse(HTTParty.get("#{EXT_API_URL}/users?limit=1").body)['users'][0]
    get "/api/recent_purchases/#{user['username']}"
    json = JSON.parse(last_response.body)
    expect(last_response.status).to be 200
    expect(json.first['recent'].count).to be > json.last['recent'].count
  end

  it 'caches responses' do
    user = JSON.parse(HTTParty.get("#{EXT_API_URL}/users?limit=1").body)['users'][0]
    get "/api/recent_purchases/#{user['username']}"
    expect(redis[user['username']]).to_not be_nil
    expect(last_response.body).to eq(redis[user['username']])
  end
end
