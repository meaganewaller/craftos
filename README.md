# CraftOS

CraftOS is a collection of Ruby libraries for building software around **fiber arts** (knitting, crochet, weaving, and yarn-based making).

Fiber arts and crafts involve structured systems:

- stitch counts
- row counts
- gauge
- yarn yardage
- skein weights
- fiber blends
- pattern repeats
- garment sizing

CraftOS provides composable Ruby libraries that model these concepts with precise units, dimensional safety, and domain-specific APIs.

## Gems

Each library is released independently but developed together into this monorepo.

### `fiber_units`

Core unitt system for fiber measurements.

Provides domain-specific numeric types such as:

- `Length`
- `Weight`
- `StitchCount`
- `RowCount`
- `Ratio`

Example:

```ruby
210.yards / 100.grams
# => FiberUnits::Ratio
```

### `fiber_gauge`

Models knitting or crochet gauge

```ruby
gauge = FiberGauge::Gauge.new(
  stitches: 18.stitches,
  rows: 24.rows,
  width: 4.inches
)

gauge.spi
# => 4.5
```

### `fiber_pattern`

Pattern mathematics and transformations.

Includes:

- gauge scaling
- stitch repeat handling
- sizing calculations

Example:

```ruby
sizing = FiberPattern::Sizing.new(gauge: gauge)

sizing.cast_on_for(20.inches)
# => 90.stitches
```

### `yarn_skein`

Models yarn properties and skein math.

Includes:

- yarn weight classification
- fiber blends
- yardage calculations
- skein requirements

Example:

```ruby
yarn = YarnSkein::Yarn.new(
  brand: "Malabrigo",
  line: "Rios",
  yardage: 210.yards,
  skein_weight: 100.grams
)

yarn.weight_category
# => :worsted
```

## Apps

### `gauge-calculator`

A web application for calculating knitting and crochet gauge. Built with Sinatra, it provides a UI and JSON API for computing stitches per inch, rows per inch, and required stitch/row counts for target dimensions.

Depends on `fiber_units` and `fiber_gauge`.

```
cd apps/gauge-calculator
bundle install
bundle exec rackup
```

Deployed to [Render](https://render.com) automatically when changes to the app or its gem dependencies land on `main` and CI passes.

## Repository Structure

```
craftos
├── apps
│   └── gauge-calculator
├── gems
│   ├── fiber_units
│   ├── fiber_gauge
│   ├── fiber_pattern
│   └── yarn_skein
│
├── render.yaml
├── Gemfile
├── Rakefile
└── README.md
```

Each gem contains its own:

- gemspec
- tests
- version
- release lifecycle

Each app contains its own:

- Gemfile
- Rakefile
- tests
- deployment configuration

## Development

Clone the repository

```
git clone https://github.com/meaganewaller/craftos
cd craftos
```

Install the dependencies

```
bundle install
bundle exec rake bundle:all
```

Run the full test suite:

```
bundle exec rake test:all
```

Run linting:

```
bundle exec rake lint:all
```

## Releasing Gems

Each gem is versioned and released independently.

To release a gem:

```
git checkout -b release/fiber_units-v0.3.2
```

On that branch, update the target gem's version file and changelog, then open a PR into `main`.

GitHub Actions marks the PR `Ready for Release` only when:

- the branch name matches `release/<gem>-v<version>`
- only one gem is being released
- that gem's `version.rb` matches the branch version
- that gem's `CHANGELOG.md` includes the new version entry and leaves `Unreleased` empty
- the gem still builds cleanly

After the PR is merged, GitHub Actions publishes the gem to RubyGems, creates the matching git tag, and creates the GitHub release automatically.

## Philosophy

CraftOS has few guiding principles:

- Fiber craft concepts are trewated as first-class objects
- Units prevent invalid operations to ensure dimensional safety
- Each gem does one thing well and integrates with the others
- Code should read like the domain:
```
20.stitches / 4.inches
```

## Future Directions

CraftOS is intended to support more advanced fiber tooling, including:

- pattern grading engines
- yarn substitution tools
- stash management systems
- garment sizing engines
- pattern editors

## License

MIT
