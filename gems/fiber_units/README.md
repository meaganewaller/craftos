# fiber_units

Typed measurement units for fiber arts and crafting systems.

`fiber_units` provides a small, type-safe unit system for working with measurements common in knitting, crochet, and other crafts.

It supports:

* length units (`inches`, `centimeters`, `yards`, etc.)
* weight units (`grams`, `ounces`, `pounds`, etc.)
* stitch counts
* row counts
* safe arithmetic between compatible units
* automatic unit conversion

## Installation

Add to your Gemfile:

```ruby
gem "fiber_units"
```

Then run:

```bash
bundle install
```

Or install directly:

```bash
gem install fiber_units
```

## Basic Usage

```ruby
require "fiber_units"

4.inches
10.centimeters
210.yards
100.grams
```

Each returns a typed measurement object.

Example:

```ruby
length = 4.inches

length.value
# => 4

length.unit
# => :inches
```

## Unit Conversion

Convert between compatible units:

```ruby
4.inches.to(:centimeters)
# => 10.16 cm

210.yards.to(:meters)
# => 192.024 m

100.grams.to(:ounces)
# => 3.527 oz
```

## Arithmetic

Compatible units can be combined safely.

```ruby
4.inches + 2.inches
# => 6 inches

10.inches - 4.inches
# => 6 inches
```

Cross-unit arithmetic works automatically.

```ruby
2.yards + 36.inches
# => 3 yards
```

Internally calculations happen in **base units** and then convert back.

## Dimension Safety

Invalid operations raise errors.

```ruby
4.inches + 100.grams
# => FiberUnits::DimensionError
```

This prevents subtle math bugs.

## Ratios

Dividing measurements produces ratios.

```ruby
210.yards / 100.grams
# => 2.1 yards/grams
```

This is useful for yarn metrics like **grist**.

## Stitch and Row Counts

Fiber-specific counts are supported.

```ruby
20.stitches
32.rows
```

Arithmetic works as expected:

```ruby
20.stitches + 10.stitches
# => 30 stitches
```

## Supported Length Units

```
millimeters
centimeters
meters
inches
feet
yards
```

Example:

```ruby
5.centimeters
2.yards
12.inches
```

## Supported Weight Units

```
grams
kilograms
ounces
pounds
```

Example:

```ruby
100.grams
8.ounces
1.pounds
```

## Internal Model

All measurements inherit from a shared base class:

```
FiberUnits::Measurement
```

Each dimension defines its unit conversion table:

```ruby
class Length < Measurement
  FACTORS = {
    millimeters: 1.0,
    centimeters: 10.0,
    meters: 1000.0,
    inches: 25.4,
    feet: 304.8,
    yards: 914.4
  }
end
```

Arithmetic works by:

1. converting to base units
2. performing the calculation
3. converting back to the original unit

## Example: Yarn Grist

```ruby
yardage = 210.yards
weight  = 100.grams

grist = yardage / weight
# => 2.1 yards/gram
```

## Example: Gauge Math

```ruby
stitches = 18.stitches
width = 4.inches

spi = stitches / width
# => 4.5 stitches per inch
```

## Extending the Library

Adding a new measurement dimension is simple.

Example:

```ruby
class Area < FiberUnits::Measurement
  FACTORS = {
    square_millimeters: 1.0,
    square_centimeters: 100.0,
    square_meters: 1_000_000.0
  }
end
```

Everything else (conversion, arithmetic) works automatically.

## Philosophy

Craft software often relies on raw integers or floats for measurements, which leads to subtle bugs.

`fiber_units` aims to make craft math:

* **explicit**
* **type-safe**
* **composable**
* **pleasant to read**

Example:

```ruby
2.yards + 36.inches
```

reads like real-world math.

## Development

Run tests:

```bash
bundle exec rspec
```

The library includes extensive tests covering:

* conversions
* arithmetic
* ratios
* DSL methods
* dimension safety

## License

MIT License

# Future Ideas

Planned features include:

* comparison operators (`4.inches > 10.cm`)
* gauge utilities
* yarn grist helpers
* area and volume units
* pattern math helpers
