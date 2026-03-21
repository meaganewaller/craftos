require "./config/environment"
require "rack-flash"

class ApplicationController < Sinatra::Base
  configure do
    set :public_folder, "public"
    set :views, "app/views"
    enable :sessions
    set :session_secret, ENV.fetch("SESSION_SECRET") { SecureRandom.hex(64) }
    use Rack::Flash, sweep: true
  end

  get "/" do
    erb :index
  end
end
