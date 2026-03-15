# yarn_skein

A Ruby domain model for yarn.

`yarn_skein` models the real structural properties of yarn used in knitting, crochet, and other fiber crafts. It builds on typed measurements (via `fiber_units`) to represent yarn attributes like yardage, skein weight, and grist in a clear and safe way.

Instead of passing around raw numbers like `210` or `100`, yarn properties are expressed using typed units.

```ruby
210.yards
100.grams
```

This makes calculations such as **grist**, **weight category**, and **yardage estimates** straightforward and reliable.

## Installation

Add to your Gemfile:

```ruby
gem "yarn_skein"
```

Then install:

```bash
bundle install
```

## Basic Usage

```ruby
require "yarn_skein"

yarn = YarnSkein::Yarn.new(
  brand: "Malabrigo",
  line: "Rios",
  yardage: 210.yards,
  skein_weight: 100.grams
)
```

## Yarn Properties

A yarn object models the real characteristics of a skein.

```ruby
yarn.brand
# => "Malabrigo"

yarn.line
# => "Rios"

yarn.yardage
# => 210 yards

yarn.skein_weight
# => 100 grams
```

## Grist

**Grist** is the relationship between yardage and weight.

It measures how many yards of yarn exist per gram of fiber.

```ruby
yarn.grist
# => 2.1 yards per gram
```

Internally:

```ruby
yardage / skein_weight
```

This metric helps compare yarns with different fiber types or densities.

Example:

| Yarn           | Yardage | Weight | Grist |
| -------------- | ------- | ------ | ----- |
| Wool DK        | 210 yd  | 100 g  | 2.1   |
| Wool Fingering | 400 yd  | 100 g  | 4.0   |

Higher grist = lighter yarn.

## Weight Category

The gem can estimate a yarn’s **standard weight category** from its yardage.

```ruby
yarn.weight_category
# => :worsted
```

Weight categories follow Craft Yarn Council guidelines.

Example:

| Category    | Approx yards per 100g |
| ----------- | --------------------- |
| lace        | 800+                  |
| fingering   | 350–450               |
| sport       | 300–350               |
| dk          | 220–300               |
| worsted     | 180–220               |
| aran        | 140–180               |
| bulky       | 100–140               |
| super_bulky | <100                  |

## Fiber Content

Yarns often contain multiple fibers.

```ruby
YarnSkein::Yarn.new(
  brand: "Malabrigo",
  line: "Rios",
  fiber_content: [
    ["merino wool", 100]
  ],
  yardage: 210.yards,
  skein_weight: 100.grams
)
```

Future versions may support richer fiber modeling.

## Example: Comparing Yarns

```ruby
rios = YarnSkein::Yarn.new(
  brand: "Malabrigo",
  line: "Rios",
  yardage: 210.yards,
  skein_weight: 100.grams
)

sock = YarnSkein::Yarn.new(
  brand: "Malabrigo",
  line: "Sock",
  yardage: 440.yards,
  skein_weight: 100.grams
)

rios.grist
# => 2.1

sock.grist
# => 4.4
```

## Future Capabilities

Planned features include:

* yarn substitution recommendations
* yardage calculators
* gauge compatibility helpers
* skein count estimators
* stash modeling
* fiber blend utilities

Example future API:

```ruby
pattern.required_yardage
# => 420 yards

yarn.skeins_required(pattern)
# => 2
```

## Relationship to fiber_units

`yarn_skein` builds on the `fiber_units` gem.

`fiber_units` provides the measurement system:

```
4.inches
210.yards
100.grams
```

`yarn_skein` uses those units to model yarn properties.

## Development

Run tests:

```bash
bundle exec rspec
```

## License

MIT License
