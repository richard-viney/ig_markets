# Ruby IG Markets Dealing Platform Gem

[![Build Status][travis-ci-badge]][travis-ci-home]

Easily access the IG Markets Dealing Platform from Ruby. Supports accessing an account's positions, history, transactions,
working orders, current profit/loss, and other parts of the IG Markets Dealing Platform.

Written against the offical REST API available at http://labs.ig.com/rest-trading-api-reference.

An IG Markets live or demo account is needed in order to use this gem.

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

    dealing_platform = IGMarkets::DealingPlatform.new
    dealing_platform.login username: '...', password: '...', api_key: '...', api: :demo

    puts dealing_platform.accounts.inspect
    puts dealing_platform.positions.inspect

## Contributors

This gem was originally written by Richard Viney.
