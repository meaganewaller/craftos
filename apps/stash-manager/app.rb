require "json"
require "securerandom"
require "sinatra/base"

class StashManagerApp < Sinatra::Base
  configure do
    set :root, File.expand_path(__dir__)
    set :views, File.join(root, "views")
    set :public_folder, File.join(root, "public")
    set :static, true
    set :environment, ENV.fetch("SINATRA_ENV", "development").to_sym
    enable :sessions
    set :session_secret, ENV.fetch("SESSION_SECRET") { SecureRandom.hex(64) }
  end

  configure :test do
    set :protection, except: :host_authorization
  end

  helpers do
    def current_user
      @current_user ||= User[session[:user_id]] if session[:user_id]
    end

    def require_login!
      unless current_user
        halt 401, {error: "Unauthorized"}.to_json
      end
    end

    def require_login_html!
      redirect "/login" unless current_user
    end
  end

  # --- Auth pages ---

  get "/login" do
    erb :login
  end

  get "/signup" do
    erb :signup
  end

  # --- Auth API ---

  post "/api/auth/signup" do
    content_type :json
    data = request_params

    username = data["username"].to_s.strip
    password = data["password"].to_s

    halt 422, {error: "Username is required"}.to_json if username.empty?
    halt 422, {error: "Password must be at least 8 characters"}.to_json if password.length < 8

    if User.where(username: username).any?
      halt 422, {error: "Username already taken"}.to_json
    end

    user = User.new(username: username)
    user.password = password
    user.save

    session[:user_id] = user.id
    {user: {id: user.id, username: user.username}}.to_json
  end

  post "/api/auth/login" do
    content_type :json
    data = request_params

    user = User.where(username: data["username"].to_s.strip).first

    unless user&.authenticate(data["password"].to_s)
      halt 401, {error: "Invalid username or password"}.to_json
    end

    session[:user_id] = user.id
    {user: {id: user.id, username: user.username}}.to_json
  end

  get "/api/auth/session" do
    content_type :json
    if current_user
      {user: {id: current_user.id, username: current_user.username}}.to_json
    else
      halt 401, {error: "Not logged in"}.to_json
    end
  end

  post "/logout" do
    session.clear
    redirect "/login"
  end

  # --- Stash routes (protected) ---

  get "/" do
    require_login_html!
    erb :stash
  end

  get "/api/stash" do
    content_type :json
    require_login!
    service = StashService.new(current_user)
    service.list(search: params["search"]).to_json
  end

  post "/api/stash" do
    content_type :json
    require_login!
    validate_params!("brand", "line", "yardage", "skein_weight")
    validate_positive!("yardage", "skein_weight")

    service = StashService.new(current_user)
    result = service.add(
      brand: request_params["brand"],
      line: request_params["line"],
      colorway: request_params["colorway"],
      yardage: request_params["yardage"],
      skein_weight: request_params["skein_weight"],
      quantity: request_params["quantity"]
    )

    if result[:errors]
      halt 422, {error: result[:errors].join(", ")}.to_json
    end

    status 201
    result[:entry].to_json
  end

  delete "/api/stash/:id" do
    content_type :json
    require_login!
    service = StashService.new(current_user)

    if service.remove(params["id"].to_i)
      {deleted: true}.to_json
    else
      halt 404, {error: "Entry not found"}.to_json
    end
  end

  get "/api/stash/check" do
    content_type :json
    require_login!
    yardage = params["yardage"]&.to_f

    unless yardage && yardage > 0
      halt 422, {error: "yardage parameter must be positive"}.to_json
    end

    service = StashService.new(current_user)
    yarn_id = params["yarn_id"]&.to_i
    service.check_yardage(yardage, yarn_id: (yarn_id.nil? || yarn_id == 0) ? nil : yarn_id).to_json
  end

  post "/api/stash/project-check" do
    content_type :json
    require_login!
    data = request_params

    mode = data["mode"]
    halt 422, {error: "mode must be 'simple' or 'colorwork'"}.to_json unless %w[simple colorwork].include?(mode)

    gauge = data["gauge"]
    unless gauge.is_a?(Hash) && %w[stitches rows width].all? { |k| gauge[k].to_f > 0 }
      halt 422, {error: "gauge requires positive stitches, rows, and width"}.to_json
    end

    dims = data["dimensions"]
    unless dims.is_a?(Hash) && %w[width height].all? { |k| dims[k].to_f > 0 }
      halt 422, {error: "dimensions requires positive width and height"}.to_json
    end

    service = ProjectCheckService.new(current_user)
    gauge_params = {stitches: gauge["stitches"], rows: gauge["rows"], width: gauge["width"], height: gauge["height"]}
    dimensions = {width: dims["width"], height: dims["height"]}

    result = if mode == "simple"
      ids = data["stash_entry_ids"]
      halt 422, {error: "stash_entry_ids is required"}.to_json unless ids.is_a?(Array) && !ids.empty?
      service.check_rectangle(gauge_params: gauge_params, dimensions: dimensions, stash_entry_ids: ids)
    else
      colors = data["colors"]
      halt 422, {error: "colors is required for colorwork mode"}.to_json unless colors.is_a?(Hash) && !colors.empty?

      technique = data["technique"]
      halt 422, {error: "technique must be 'stranded' or 'intarsia'"}.to_json unless %w[stranded intarsia].include?(technique)

      service.check_colorwork(
        gauge_params: gauge_params,
        dimensions: dimensions,
        technique: technique,
        color_assignments: colors
      )
    end

    if result[:error]
      halt 422, {error: result[:error]}.to_json
    end

    result.to_json
  end

  error 422 do
    content_type :json
    response.body
  end

  private

  def validate_params!(*keys)
    missing = keys.select { |k| request_params[k].nil? }
    unless missing.empty?
      halt 422, {error: "Missing required parameters: #{missing.join(", ")}"}.to_json
    end
  end

  def validate_positive!(*keys)
    invalid = keys.select { |k| request_params[k].to_f <= 0 }
    unless invalid.empty?
      halt 422, {error: "Parameters must be positive: #{invalid.join(", ")}"}.to_json
    end
  end

  def request_params
    @request_params ||= begin
      body = env["rack.input"].read.to_s
      body.empty? ? {} : JSON.parse(body)
    rescue JSON::ParserError
      {}
    end
  end
end
