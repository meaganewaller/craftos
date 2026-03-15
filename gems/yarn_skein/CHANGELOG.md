## [Unreleased]

### Changed
- GitHub Actions now publishes on version tag pushes and creates a matching GitHub release

## [0.1.1] - 2026-03-14
### Added
- `YarnSkein::Yarn` for modeling a skein's brand, line, yardage, skein weight, and optional fiber content
- Grist and `yards_per_100g` helpers for comparing yarn density with typed `fiber_units` measurements
- Weight category lookup via `YarnSkein::WeightCategory` for standard yarn classifications
- Skein math helpers including `skeins_required`, `total_yardage`, and similar-weight comparisons
- `YarnSkein::FiberBlend` for representing fiber composition percentages
- Initial release
