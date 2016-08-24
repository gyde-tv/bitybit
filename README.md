# Bitybit

Bitybit is a very simple implementation of bitmap indexes (and associated lookups) on top of [Redis](https://redis.io/).

It's designed to be easy to drop in when Redis is already part of your infrastructure, suitable for quick prototyping
(and understanding of how data is used) and pretty quick! It's suitable for adhoc queries, and is designed for bitmap
indexes only.

In general, you're responsible for:

* Generating feature sets from a given object
* Ensuring they can be discretized into a finite number of buckets
* Invoking the indexer / lookup
* Generate queries as hashes

And in return we:

* Normalize them into bitmap features
* Parse and process queries into bitmap operations
* Talk to redis
* Getting back list of ids for a given query.
* Quick estimated counts

The library takes a very hands of approach, focusing on letting you use it as a tool. Once you start hitting the boundaries
of it, it's worth looking at other options such as [ElasticSearch](https://elastic.co/) and proper information retrieval systems.

## Performance?

Amusingly, Whilst redis is incredibly fast at the actual bitmap operations, the limiting factor is currently parsing queries
and converting into a bitmap tree. We try to optimize this where possible (and cache / pipeline).

Space wise, the space used is per (feature, value) unique tuple, and generally proportional to the maximum id of an item in
that feature (these are bitmaps...)

**TODO:** Model performance better here.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bitybit'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bitybit

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/bitybit. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


## Thanks

Thanks to:

* [Matt Allen](https://github.com/mattallen) - The original inspiration, based on a chat with him, and help pairing on initial prototypes.
* [Matt Delves](https://github.com/mattdelves) - Help pairing on the early stage and exploring the concept.
* [Charlie Somerville](https://github.com/charliesome) Took my `fast_bitset` code, and made it much, much faster. Damn you Charlie!
