require "json"
require "sinatra/base"

class StashManagerApp < Sinatra::Base
  configure do
    set :root, File.expand_path(__dir__)
    set :views, File.join(root, "views")
    set :public_folder, File.join(root, "public")
    set :static, true
    set :environment, ENV.fetch("SINATRA_ENV", "development").to_sym
  end

  configure :test do
    set :protection, except: :host_authorization
  end

  get "/" do
    erb :stash
  end

  get "/api/stash" do
    content_type :json
    service = StashService.new
    service.list(search: params["search"]).to_json
  end

  post "/api/stash" do
    content_type :json
    validate_params!("brand", "line", "yardage", "skein_weight")
    validate_positive!("yardage", "skein_weight")

    service = StashService.new
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
    service = StashService.new

    if service.remove(params["id"].to_i)
      {deleted: true}.to_json
    else
      halt 404, {error: "Entry not found"}.to_json
    end
  end

  get "/api/stash/check" do
    content_type :json
    yardage = params["yardage"]&.to_f

    unless yardage && yardage > 0
      halt 422, {error: "yardage parameter must be positive"}.to_json
    end

    service = StashService.new
    yarn_id = params["yarn_id"]&.to_i
    service.check_yardage(yardage, yarn_id: (yarn_id.nil? || yarn_id == 0) ? nil : yarn_id).to_json
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
