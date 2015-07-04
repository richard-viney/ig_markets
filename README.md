# Ruby IG Markets Dealing Platform Gem

[![Build Status][travis-ci-badge]][travis-ci-home]

Easily access the IG Markets Dealing Platform from Ruby. Supports accessing an account's positions, history, transactions,
working orders, current profit/loss, and other parts of the IG Markets Dealing Platform.

Written against the offical REST API available at http://labs.ig.com/rest-trading-api-reference.

A IG Markets live or demo account is needed in order to use this gem.

This software is provided under the MIT license (see the `LICENSE` file). You must read and agree to this license in order
to use this software.

[travis-ci-home]: http://travis-ci.org/rviney/ig_markets
[travis-ci-badge]: https://travis-ci.org/rviney/ig_markets.svg?branch=master

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

## Legal

The `ig_markets` gem is licensed under the MIT license, a copy of which is provided.
