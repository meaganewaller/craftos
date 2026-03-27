require "json"
require "sinatra/base"

class PatternEditorApp < Sinatra::Base
  configure do
    set :root, File.expand_path(__dir__)
    set :views, File.join(root, "views")
    set :public_folder, File.join(root, "public")
    set :static, true
    set :environment, ENV.fetch("SINATRA_ENV", "development").to_sym
  end

  configure :production do
    set :protection, except: :host_authorization
  end

  configure :test do
    set :protection, except: :host_authorization
  end

  get "/" do
    erb :editor
  end

  get "/api/stitch_patterns" do
    content_type :json
    PieceService.stitch_pattern_list.to_json
  end

  post "/api/piece" do
    content_type :json
    validate_gauge_params!
    validate_piece_params!

    service = build_service
    service.results.to_json
  end

  error 422 do
    content_type :json
    response.body
  end

  private

  def validate_gauge_params!
    gauge = request_params["gauge"]
    halt 422, {error: "Missing required parameter: gauge"}.to_json if gauge.nil?

    %w[stitches rows width].each do |key|
      if gauge[key].nil?
        halt 422, {error: "Missing required gauge parameter: #{key}"}.to_json
      end
      if gauge[key].to_f <= 0
        halt 422, {error: "Gauge parameter must be positive: #{key}"}.to_json
      end
    end
  end

  def validate_piece_params!
    piece = request_params["piece"]
    halt 422, {error: "Missing required parameter: piece"}.to_json if piece.nil?

    %w[width height].each do |key|
      if piece[key].nil?
        halt 422, {error: "Missing required piece parameter: #{key}"}.to_json
      end
      if piece[key].to_f <= 0
        halt 422, {error: "Piece parameter must be positive: #{key}"}.to_json
      end
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
    PieceService.new(
      gauge_params: request_params.fetch("gauge"),
      piece_params: request_params.fetch("piece"),
      stitch_pattern_name: request_params["stitch_pattern"],
      repeat_params: request_params["repeat"],
      unit: request_params.dig("gauge", "unit")
    )
  end
end
