# Arable

The days of writing `.arel_table` are gone! Arable enables you to write cleaner Arel (SQL) queries.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'arable'
```

And then execute:

    $ bundle install

Extend `ApplicationRecord`, `ActiveRecord::Base` or your base class that is being used by the models:

```ruby
class ApplicationRecord < ActiveRecord::Base
    ...
    extend Arable::ActiveRecordExtension
    ...
end

```

## Usage

If you have a model `User birthday:date`, from now on you can use `User.birthday` directly. This acts as a shorthand for `User.arel_table[:birthday]`:

```ruby
def birthdays
    User.where(User.birthday.eq(Date.today))
end
```

This goes very well together with [arel-extensions gem](https://github.com/Faveod/arel-extensions). If you have both, you can write:

```ruby
def legal_aged_users
    User.where(User.birthday <= 18.years.ago)
end
```

## Roadmap

- [x] Support schema.rb
- [x] Support structure.sql
- [ ] Add tests

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests (which are coming soon). You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dvisockas/arable.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
