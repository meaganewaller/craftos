## [Unreleased]

### Changed
- GitHub Actions now publishes on version tag pushes and creates a matching GitHub release

## [0.3.1] - 2026-03-14

## [0.3.0] - 2026-03-14

### Added
- Shared `Count` base class for `RowCount` and `StitchCount`
- Equality and comparison behavior for `StitchCount` and `RowCount`
- Coverage for shared count behavior through `RowCount` and `StitchCount` specs

## [0.2.0] - 2026-03-09

### Added
- Comparison operators (`<`, `>`, `<=`, `>=`, `==`, `!=`) for `Measurement` class
- Support for cross-unit comparisons (e.g., `4.inches > 10.centimeters`)
- Dimension safety checks in comparisons (raises error for incompatible units)

## [0.1.0] - 2026-03-09

### Added
- Core `Measurement` class for representing and manipulating fiber unit measurements
- Dimension types: `Length`, `Weight`, `RowCount`, and `StitchCount`
- Conversion framework with `LengthConversion` and `WeightConversion` support
- Unit operations: addition, subtraction, multiplication, and division
- `Ratio` class for expressing relationships between measurements
- Numeric extensions for DSL-style usage (e.g., `10.cm`, `100.grams`)
- Comprehensive RBS type signatures for type checking support
- Initial release
