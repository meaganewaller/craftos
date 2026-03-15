# fiber_gauge

A Ruby library for **knitting and crochet gauge calculations**.

`fiber_gauge` models gauge swatches and provides helpers for converting between:

* stitches
* rows
* width
* height

This allows you to perform the core math required for **pattern sizing, swatch calculations, and garment scaling**.

The gem integrates with **[`fiber_units`](https://github.com/meaganewaller/fiber_units)**, which provides typed units for measurements and counts.

# Installation

Add this line to your application's Gemfile:

```ruby
gem "fiber_gauge"
```

And then execute:

```
bundle install
```

Or install it directly:

```
gem install fiber_gauge
```

# Dependencies

`fiber_gauge` expects `fiber_units` to be installed.

`fiber_units` provides the domain primitives used throughout the API:

```
10.stitches
24.rows
4.inches
10.centimeters
```

# Basic Usage

A gauge swatch is defined by:

* stitch count
* row count
* swatch width

Example swatch:

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

# Stitches Per Inch

```ruby
gauge.spi
# => 4.5
```

# Rows Per Inch

```ruby
gauge.rpi
# => 6
```

# Calculate Width From Stitch Count

Determine how wide a piece will be given a stitch count.

```ruby
gauge.width_for_stitches(90.stitches)
# => 20 inches
```

# Calculate Height From Row Count

```ruby
gauge.height_for_rows(60.rows)
# => 10 inches
```

# Calculate Required Stitches

Determine how many stitches are needed to reach a target width.

```ruby
gauge.required_stitches(20.inches)
# => 90 stitches
```

# Calculate Required Rows

```ruby
gauge.required_rows(10.inches)
# => 60 rows
```

# Unit Conversion

Because the gem relies on `fiber_units`, you can mix units freely:

```ruby
gauge = FiberGauge::Gauge.new(
  stitches: 20.stitches,
  rows: 28.rows,
  width: 10.centimeters
)

gauge.required_stitches(40.centimeters)
```

All calculations are normalized internally.

# Example: Sweater Sizing

```ruby
gauge = FiberGauge::Gauge.new(
  stitches: 18.stitches,
  rows: 24.rows,
  width: 4.inches
)

chest = 38.inches

cast_on = gauge.required_stitches(chest)
# => 171 stitches
```

# Design Goals

`fiber_gauge` is designed to:

* model gauge as a **first-class domain object**
* work naturally with **typed measurement units**
* enable **pattern math and garment sizing**
* remain **small and composable**

It is intended to integrate with other fiber tools such as:

- [fiber_units](https://github.com/meaganewaller/fiber_units)
- [yarn_skein](https://github.com/meaganewaller/yarn_skein)

# Contributing

Bug reports and pull requests are welcome.

# License

MIT License
