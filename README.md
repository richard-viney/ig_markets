# Ruby IG Markets Dealing Platform Gem

[![Build Status][travis-ci-badge]][travis-ci-link] [![Test Coverage][test-coverage-badge]][test-coverage-link]
[![Code Climate][code-climate-badge]][code-climate-link] [![Dependencies][dependencies-badge]][dependencies-link]
[![MIT License][license-badge]][license-link] [![Documentation][docs-badge]][docs-link]

Easily access the IG Markets Dealing Platform from Ruby with this gem. Written against the
[official REST API](http://labs.ig.com/rest-trading-api-reference).

Includes support for:

* Accounts
* Activity history
* Transaction history
* Positions
* Sprint market positions
* Working orders
* Deal confirmations
* Markets
* Market hierarchy
* Market searches
* Historical prices
* Watchlists
* Client sentiment

An IG Markets production or demo trading account is needed in order to use this gem.

[travis-ci-link]: http://travis-ci.org/rviney/ig_markets
[travis-ci-badge]: https://travis-ci.org/rviney/ig_markets.svg?branch=master
[test-coverage-link]: https://codeclimate.com/github/rviney/ig_markets/coverage
[test-coverage-badge]: https://codeclimate.com/github/rviney/ig_markets/badges/coverage.svg
[code-climate-link]: https://codeclimate.com/github/rviney/ig_markets
[code-climate-badge]: https://codeclimate.com/github/rviney/ig_markets/badges/gpa.svg
[dependencies-link]: https://gemnasium.com/rviney/ig_markets
[dependencies-badge]: https://gemnasium.com/rviney/ig_markets.svg
[license-link]: https://github.com/rviney/ig_markets/blob/master/LICENSE.md
[license-badge]: https://img.shields.io/badge/license-MIT-blue.svg
[docs-link]: https://inch-ci.org/github/rviney/ig_markets
[docs-badge]: http://inch-ci.org/github/rviney/ig_markets.svg?branch=master

## License

Licensed under the MIT license. You must read and agree to its terms to use this software.

## Requirements

Ruby 2.0 or later.

## Installation

Add the following to your `Gemfile`

```ruby
gem 'ig_markets', git: 'https://github.com/rviney/ig_markets.git'
```
Then run

```
bundle install
```

## Usage

```ruby
ig = IGMarkets::DealingPlatform.new

# Session
ig.sign_in 'username', 'password', 'api_key', :demo
ig.sign_out

# Account
ig.account.all
ig.account.recent_activities 24 * 60 * 60
ig.account.recent_transactions 24 * 60 * 60
ig.account.activities_in_date_range Date.today.prev_month(2), Date.today.prev_month(1)
ig.account.transactions_in_date_range Date.today.prev_month(2), Date.today.prev_month(1)

# Dealing
ig.deal_confirmation 'deal_reference'

# Positions
ig.positions.all
ig.positions['deal_id']

# Sprint market positions
ig.sprint_market_positions.all

# Working orders
ig.working_orders.all

# Markets
ig.market_hierarchy
ig.markets 'UA.D.AAPL.CASH.IP'
ig.market_search 'APPL'
ig.recent_prices 'CS.D.EURUSD.MINI.IP', :day, 10
ig.prices_in_date_range 'CS.D.EURUSD.MINI.IP', :day, Date.today.prev_month(2), Date.today.prev_month(1)

# Watchlists
ig.watchlists.all
ig.watchlists.create 'test', 'CS.D.EURUSD.MINI.IP', 'UA.D.AAPL.CASH.IP'
ig.watchlists['watchlist_id'].delete
ig.watchlists['watchlist_id'].markets
ig.watchlists['watchlist_id'].add_market 'UA.D.AAPL.CASH.IP'
ig.watchlists['watchlist_id'].remove_market 'UA.D.AAPL.CASH.IP'

# Client sentiment
ig.client_sentiment['EURUSD']
ig.client_sentiment['EURUSD'].related

# Miscellaneous
ig.applications
```

## Documentation

API documentation is available [here](http://www.rubydoc.info/github/rviney/ig_markets/master).

## Contributors

Gem created by Richard Viney. All contributions welcome.
