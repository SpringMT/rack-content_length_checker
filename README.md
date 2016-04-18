# Rack::ContentLengthChecker [![Build Status](https://travis-ci.org/SpringMT/rack-content_length_checker.svg?branch=master)](https://travis-ci.org/SpringMT/rack-content_length_checker)

### English

### Japanese
* リクエストのサイズ(Content-Length)を監視、ロギングを行うrackミドルウェアです。

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rack-content_length_checker'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-content_length_checker

## Usage
### English

### Japanese
#### warn、fatalの設定
* Content-Lengthが1.5MB〜2.0 MBの時にlog level warnでログをだし、2.0MB以上の場合log level fatalでログを出す場合の設定
  * rubyのLoggerを使う
  * この設定では、ログを吐くだけ

```
use Rack::ContentLengthChecker,
  warn: {length: 1_500_000}, # 1.5MB
  fatal: {length: 2_000_000}, # 2.0 MB
  logger: Logger.new(STDOUT)
```

#### エラーを返す場合
* エラーを返す場合は、`is_error`のオプションを使って下さい
  * 下記例では、Content-Lengthが1.5MB〜2.0 MBの時にlog level warnでログをだし、2.0MB以上の場合log level fatalでログを出し、エラーを返します。
  * エラーを帰す場合は、HTTP Statusは`413`となります。

```
use Rack::ContentLengthChecker,
  warn: {length: 1_500_000}, # 1.5MB
  fatal: {length: 2_000_000, is_error: true}, # 2.0 MB
  logger: Logger.new(STDOUT)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rack-content_length_checker.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

