# frozen_string_literal: true

require "yaml"

module YarnSkein
  class Catalog
    def initialize(data_dir: nil)
      @data_dir = data_dir || default_data_dir
      @yarns = nil
    end

    def all
      load_yarns
    end

    def filter(brand: nil, weight_category: nil, fiber: nil)
      results = all
      results = results.select { |y| y.brand.downcase == brand.downcase } if brand
      results = results.select { |y| y.weight_category == weight_category.to_sym } if weight_category
      results = results.select { |y| y.fiber_content&.contains?(fiber.to_sym) } if fiber
      results
    end

    def brands
      all.map(&:brand).uniq.sort
    end

    def find(brand:, line:)
      all.detect { |y| y.brand.downcase == brand.downcase && y.line.downcase == line.downcase }
    end

    private

    def load_yarns
      @yarns ||= Dir.glob(File.join(@data_dir, "*.yml")).reject { |f| File.basename(f).start_with?("_") }.flat_map { |file| parse_brand_file(file) }
    end

    def parse_brand_file(file)
      data = YAML.safe_load_file(file, permitted_classes: [])
      brand_name = data["brand"]
      (data["yarns"] || []).filter_map do |entry|
        build_yarn(brand_name, entry)
      end
    end

    def build_yarn(brand_name, entry)
      yardage = entry["yardage"]
      skein_weight = entry["skein_weight"]
      return nil unless yardage && skein_weight

      fiber_content = nil
      if entry["fiber_content"] && !entry["fiber_content"].empty?
        fiber_hash = entry["fiber_content"].transform_keys(&:to_sym).transform_values(&:to_i)
        fiber_content = FiberBlend.new(fiber_hash)
      end

      Yarn.new(
        brand: brand_name,
        line: entry["line"],
        yardage: yardage.to_f.yards,
        skein_weight: skein_weight.to_f.grams,
        fiber_content: fiber_content
      )
    end

    def default_data_dir
      env_path = ENV["YARN_CATALOG_PATH"]
      return env_path if env_path

      File.expand_path("../../../../data/yarns", __dir__)
    end
  end
end
