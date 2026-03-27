require "json"
require "yaml"
require "sinatra/base"

class YarnSubstitutionApp < Sinatra::Base
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
    erb :substitute
  end

  post "/api/substitution" do
    content_type :json

    validate_params!("yardage", "skein_weight")
    validate_positive!("yardage", "skein_weight")

    target_attrs = {
      brand: request_params["brand"] || "My Yarn",
      line: request_params["line"] || "Target",
      yardage: request_params["yardage"],
      skein_weight: request_params["skein_weight"],
      fiber_content: parse_fiber_content(request_params["fiber_content"])
    }

    service = SubstitutionService.new(
      target_attrs: target_attrs,
      catalog: built_in_catalog
    )

    tolerance = request_params["tolerance"]&.to_f
    fiber = request_params["fiber"]&.to_sym

    results = service.matches(tolerance: tolerance, fiber: fiber)

    {
      target: service.target_info,
      matches: results.map { |yarn| yarn_to_hash(yarn) }
    }.to_json
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

  def parse_fiber_content(content)
    return nil if content.nil? || content.empty?

    if content.is_a?(Hash)
      content.transform_keys(&:to_sym).transform_values(&:to_i)
    end
  end

  def yarn_to_hash(yarn)
    result = {
      brand: yarn.brand,
      line: yarn.line,
      weight_category: yarn.weight_category,
      yards_per_100g: yarn.yards_per_100g.round(1),
      grist: yarn.grist.value.round(2)
    }
    if yarn.fiber_content
      result[:fiber_content] = yarn.fiber_content.fibers
    end
    result
  end

  def built_in_catalog
    @built_in_catalog ||= if defined?(YarnSkein::Catalog)
      yarns = YarnSkein::Catalog.new.all
      yarns.empty? ? legacy_catalog : yarns
    else
      legacy_catalog
    end
  end

  def legacy_catalog
    catalog_path = File.join(settings.root, "data", "catalog.yml")
    return [] unless File.exist?(catalog_path)

    entries = YAML.safe_load_file(catalog_path, permitted_classes: [], symbolize_names: true)
    entries.map do |entry|
      fc = entry[:fiber_content]&.transform_keys(&:to_sym)
      fc = fc ? YarnSkein::FiberBlend.new(fc) : nil
      YarnSkein::Yarn.new(
        brand: entry[:brand],
        line: entry[:line],
        yardage: entry[:yardage].to_f.yards,
        skein_weight: entry[:skein_weight].to_f.grams,
        fiber_content: fc
      )
    end
  end
end
