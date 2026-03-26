## [Unreleased]

### Added
- `YarnSkein::YardageEstimator` for estimating total yarn yardage from gauge and dimensions
- Rectangular piece estimation via `for_rectangle(width:, height:)`
- Stitch/row count estimation via `for_piece(stitches:, rows:)`
- Configurable safety margin (default 10%) for waste and joining
- Added `fiber_gauge` as a runtime dependency

## [0.2.0] - 2026-03-21

### Added
- `YarnSkein::Substitution` for finding compatible yarn substitutes from a catalog
- Matches by weight category and grist tolerance (default 15%, configurable)
- Optional fiber content filter
- Added missing `rake` and `simplecov-json` dev dependencies

## [0.1.1] - 2026-03-14
### Added
- `YarnSkein::Yarn` for modeling a skein's brand, line, yardage, skein weight, and optional fiber content
- Grist and `yards_per_100g` helpers for comparing yarn density with typed `fiber_units` measurements
- Weight category lookup via `YarnSkein::WeightCategory` for standard yarn classifications
- Skein math helpers including `skeins_required`, `total_yardage`, and similar-weight comparisons
- `YarnSkein::FiberBlend` for representing fiber composition percentages
- Initial release
