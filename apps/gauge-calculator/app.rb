require "json"
require "sinatra/base"

class GaugeCalculatorApp < Sinatra::Base
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
    erb :gauge
  end

  post "/api/gauge" do
    content_type :json
    validate_params!("stitches", "rows", "width")
    validate_positive!("stitches", "rows", "width")

    service = build_service

    {
      spi: service.spi,
      rpi: service.rpi
    }.to_json
  end

  post "/api/gauge/stitches" do
    content_type :json
    validate_params!("stitches", "rows", "width", "target_width")
    validate_positive!("stitches", "rows", "width", "target_width")

    service = build_service
    base = service.gauge.required_stitches(length_param(:target_width)).value
    adjusted = adjust_for_repeat(base)

    result = {stitches: adjusted}
    result[:base_stitches] = base if adjusted != base

    result.to_json
  end

  post "/api/gauge/rows" do
    content_type :json
    validate_params!("stitches", "rows", "width", "target_height")
    validate_positive!("stitches", "rows", "width", "target_height")

    service = build_service
    rows = service.gauge.required_rows(length_param(:target_height))

    {rows: rows.value}.to_json
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

  def build_service
    height = request_params["height"]&.to_f
    GaugeService.new(
      stitches: request_params.fetch("stitches").to_i,
      rows: request_params.fetch("rows").to_i,
      width: request_params.fetch("width").to_f,
      height: height,
      unit: request_params["unit"]
    )
  end

  def length_param(key)
    value = request_params.fetch(key.to_s).to_f
    unit = request_params["unit"] || "inches"

    value.public_send(unit)
  end

  def adjust_for_repeat(base)
    repeat = request_params["repeat"]&.to_i
    return base unless repeat && repeat > 0

    offset = (request_params["offset"] || 0).to_i
    ((base - offset).to_f / repeat).ceil * repeat + offset
  end
end
