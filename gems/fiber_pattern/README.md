# fiber_pattern

Tools for **pattern sizing, stitch repeats, and gauge-based calculations** for knitting and crochet.

`fiber_pattern` builds on the primitives provided by:

* [**fiber_units**](https://github.com/meaganewaller/fiber_units) — typed units for stitches, rows, and measurements
* [**fiber_gauge**](https://github.com/meaganewaller/fiber_gauge) — gauge swatch math

Together they enable **reliable pattern sizing and repeat calculations**.

---

# Installation

Add this line to your application's Gemfile:

```ruby
gem "fiber_pattern"
```

Then run:

```
bundle install
```

Or install directly:

```
gem install fiber_pattern
```

# Dependencies

`fiber_pattern` is designed to work with:

```
fiber_units
fiber_gauge
```

These libraries provide the domain primitives used throughout the API.

# Basic Usage

Patterns often require calculating stitch counts from gauge and measurements.

Example gauge:

```
18 stitches over 4 inches
24 rows over 4 inches
```

Create a gauge object:

```ruby
gauge = FiberGauge::Gauge.new(
  stitches: 18.stitches,
  rows: 24.rows,
  width: 4.inches
)
```

# Calculate Cast-On Stitches

You can determine how many stitches are needed for a target width.

```ruby
sizing = FiberPattern::Sizing.new(gauge: gauge)

sizing.cast_on_for(20.inches)
# => 90 stitches
```

Because:

```
18 stitches / 4 inches = 4.5 stitches per inch
20 inches × 4.5 = 90 stitches
```

# Pattern Stitch Repeats

Use `FiberPattern::Repeat` when a pattern requires stitch counts to align to a repeat.

Many patterns require stitch counts to be a **multiple of a repeat**.

Example: *multiple of 8 stitches*

```ruby
sizing = FiberPattern::Sizing.new(
  gauge: gauge,
  repeat: FiberPattern::Repeat.new(multiple: 8.stitches)
)

sizing.cast_on_for(38.inches)
# => 176 stitches
```

Calculation:

```
38 inches × 4.5 spi = 171 stitches
rounded to nearest multiple of 8 → 176
```

# Repeats With Offsets

Some stitch patterns require **multiples plus an offset**.

Example:

```
multiple of 8 + 2
```

```ruby
sizing = FiberPattern::Sizing.new(
  gauge: gauge,
  repeat: FiberPattern::Repeat.new(
    multiple: 8.stitches,
    offset: 2.stitches
  )
)

sizing.cast_on_for(38.inches)
# => 178 stitches
```

Calculation:

```
171 stitches
→ adjusted to (multiple of 8 + 2)
→ 178 stitches
```

# Gauge Scaling

You can also scale stitch and row counts from a pattern's gauge to a knitter's gauge.

```ruby
pattern_gauge = FiberGauge::Gauge.new(
  stitches: 20.stitches,
  rows: 28.rows,
  width: 4.inches
)

knitter_gauge = FiberGauge::Gauge.new(
  stitches: 18.stitches,
  rows: 24.rows,
  width: 4.inches
)

FiberPattern::Scaling.scale_stitches(
  100.stitches,
  pattern_gauge,
  knitter_gauge
)
# => 90 stitches

FiberPattern::Scaling.scale_rows(
  56.rows,
  pattern_gauge,
  knitter_gauge
)
# => 48 rows
```

# Example: Sweater Sizing

```ruby
gauge = FiberGauge::Gauge.new(
  stitches: 20.stitches,
  rows: 28.rows,
  width: 4.inches
)

sizing = FiberPattern::Sizing.new(
  gauge: gauge,
  repeat: FiberPattern::Repeat.new(multiple: 8.stitches)
)

chest = 40.inches

cast_on = sizing.cast_on_for(chest)
# => 200 stitches
```

# Design Goals

`fiber_pattern` is designed to:

* make **pattern math predictable**
* integrate with **typed fiber measurement units**
* support **repeat-based stitch patterns**
* help **scale instructions between gauges**
* stay **small and composable**

It forms part of a broader fiber tooling ecosystem:

- [fiber_units](https://github.com/meaganewaller/fiber_units)
- [yarn_skein](https://github.com/meaganewaller/yarn_skein)
- [fiber_gauge](https://github.com/meaganewaller/fiber_gauge)
- [fiber_pattern](https://github.com/meaganewaller/fiber_pattern)

# Contributing

Bug reports and pull requests are welcome.

# License

MIT License
