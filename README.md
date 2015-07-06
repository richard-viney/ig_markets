# Ruby IG Markets Dealing Platform Gem

[![Build Status][travis-ci-badge]][travis-ci-home]

Easily access the IG Markets Dealing Platform from Ruby. Currently supports read-only access to the following:

* Accounts
* Activity history
* Transaction history
* Positions
* Sprint market positions
* Working orders
* Markets
* Market hierarchy
* Market searches
* Historical prices
* Watchlists
* Client sentiment

Written against the offical REST API available at http://labs.ig.com/rest-trading-api-reference.

An IG Markets production or demo account is needed in order to use this gem.

[travis-ci-home]: http://travis-ci.org/rviney/ig_markets
[travis-ci-badge]: https://travis-ci.org/rviney/ig_markets.svg?branch=master

## License

This software is licensed under the MIT license. You must read and agree to this license in order to use this software.

## Requirements

Ruby 2.0 or later.

## Installation

Add the following to your `Gemfile`

    gem 'ig_markets', git: 'https://github.com/rviney/ig_markets.git'

Then run

    bundle install

## Usage

    ig = IGMarkets::DealingPlatform.new

    # Login
    ig.login 'username', 'password', 'api_key', :demo

    # Account
    puts ig.accounts.inspect
    puts ig.activities_in_date_range(Date.today.prev_month).inspect
    puts ig.transactions_in_date_range(Date.today.prev_month).inspect

    # Dealing
    puts ig.positions.inspect
    puts ig.sprint_market_positions.inspect
    puts ig.working_orders.inspect

    # Markets
    puts ig.market_hierarchy.inspect
    puts ig.market('UA.D.AAPL.CASH.IP').inspect
    puts ig.market_search('APPL').inspect
    puts ig.prices('CS.D.EURUSD.MINI.IP', :day, 10).inspect

    # Watchlists
    puts ig.watchlists.inspect

    # Client sentiment
    puts ig.client_sentiment('EURUSD').inspect
    puts ig.client_sentiment_related('EURUSD').inspect

    # General
    puts ig.applications.inspect

## Contributors

Gem created by Richard Viney. All contributions welcome.
