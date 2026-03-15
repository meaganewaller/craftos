## Unreleased


## [0.2.0] - 2026-03-14

### Added

- Add `Repeat` class for stitch adjustment and update `Sizing` class to utilize it
- Add `Scaling` helpers for converting stitch and row counts between gauges
- Add `Sizing#width_for` to calculate finished width from a stitch count and gauge

### Changed

- Document the public API with YARD comments for the main pattern, sizing, repeat, and scaling types
- Update the README examples to match the current `Repeat` and `Scaling` APIs

## [0.1.0] - 2026-03-14

- Adding offset repeat behavior
- Adding stitch repeat behavior
- Adding initial pattern cast-on math with `Sizing` module
- Initial release
