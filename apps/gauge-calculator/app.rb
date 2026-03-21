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

    gauge = build_gauge

    {
      spi: gauge.spi,
      rpi: gauge.rpi
    }.to_json
  end

  post "/api/gauge/stitches" do
    content_type :json

    gauge = build_gauge
    base = gauge.required_stitches(length_param(:target_width)).value
    adjusted = adjust_for_repeat(base)

    result = {stitches: adjusted}
    result[:base_stitches] = base if adjusted != base

    result.to_json
  end

  post "/api/gauge/rows" do
    content_type :json

    gauge = build_gauge
    rows = gauge.required_rows(length_param(:target_height))

    {rows: rows.value}.to_json
  end

  private

  def request_params
    @request_params ||= begin
      body = env["rack.input"].read.to_s
      body.empty? ? {} : JSON.parse(body)
    rescue JSON::ParserError
      {}
    end
  end

  def build_gauge
    GaugeService.new(
      stitches: request_params.fetch("stitches").to_i,
      rows: request_params.fetch("rows").to_i,
      width: request_params.fetch("width").to_f,
      unit: request_params["unit"]
    ).gauge
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
