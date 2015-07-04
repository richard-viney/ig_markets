# Ruby Client for the IG Markets Dealing Platform

Easily access the IG Markets dealing platform from Ruby. Supports accessing an account's positions, history, transactions,
working orders, current profit/loss, and many other parts of the IG Markets dealing platform.

A live IG Markets account or a demo account is needed in order to use this gem. This gem is provided under the
MIT license (see the `LICENSE` file), with the explicit condition that contributors have no responsibility for
any financial losses resulting from use or mis-use of this software.

Written against the offical REST API available at http://labs.ig.com/rest-trading-api-reference.

## Requirements

Ruby 2.0 or later.

## Installation

Add the following to your `Gemfile`

    gem 'ig_markets', git: 'https://github.com/rviney/ig_markets.git'

Then run

    bundle install

## Usage

    dealing_platform = IGMarkets::DealingPlatform.new
    dealing_platform.login username: '...', password: '...', api_key: '...', api: :demo # Switch to :live when ready

    accounts = dealing_platform.accounts
    positions = dealing_platform.positions

## Legal

The `ig_markets` gem is licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
