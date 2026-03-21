require "json"
require "sinatra/base"

class GaugeCalculatorApp < Sinatra::Base
  configure do
    set :root, File.expand_path(__dir__)
    set :views, File.join(root, "views")
    set :public_folder, File.join(root, "public")
    set :static, true
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
    stitches = gauge.required_stitches(length_param(:target_width))

    {stitches: stitches.value}.to_json
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
      body = request.body.read
      request.body.rewind

      parsed_body = body.empty? ? {} : JSON.parse(body)
      params.to_h.merge(parsed_body)
    rescue JSON::ParserError
      params.to_h
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
end
