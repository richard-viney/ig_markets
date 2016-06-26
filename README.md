# Ruby IG Markets Dealing Platform Gem

[![Gem][gem-badge]][gem-link]
[![Build Status][travis-ci-badge]][travis-ci-link]
[![Test Coverage][test-coverage-badge]][test-coverage-link]
[![Code Climate][code-climate-badge]][code-climate-link]
[![Dependencies][dependencies-badge]][dependencies-link]
[![Documentation][documentation-badge]][documentation-link]
[![License][license-badge]][license-link]

Easily access the IG Markets Dealing Platform from Ruby with this gem, either directly through code or by using the
provided command-line client. Written against the [official REST API](http://labs.ig.com/rest-trading-api-reference).

Includes support for:

* Activity and transaction history
* Positions
* Sprint market positions
* Working orders
* Market navigation, searches and snapshots
* Historical prices
* Watchlists
* Client sentiment

An IG Markets live or demo trading account is needed in order to use this gem.

## License

Licensed under the MIT license. You must read and agree to its terms to use this software.

## Installation

Install the latest version of the `ig_markets` gem with the following command:

```
$ gem install ig_markets
```

## Usage — Command-Line Client

The general form for invoking the command-line client is:

```
$ ig_markets COMMAND [SUBCOMMAND] --username USERNAME --password PASSWORD --api-key API-KEY [--demo] [...]
```

#### Config File

On startup `ig_markets` searches for config files named `"./.ig_markets"` and then `"~/.ig_markets"`, and if they are
present interprets their contents as command-line arguments. This can be used to avoid having to specify authentication
details with every invocation.

To do this create a config file at `"./.ig_markets"` or `"~/.ig_markets"` with the following contents:

```shell
--username USERNAME
--password PASSWORD
--api-key API-KEY
--demo              # Include only if this is a demo account
```

The following examples assume the presence of a config file that contains valid authentication details.

#### Commands

Use `ig_markets help` to get details on the options accepted by the commands and subcommands. The list of available
commands and their subcommands is:

- `ig_markets account`
- `ig_markets activities --days N [...]`
- `ig_markets confirmation DEAL-REFERENCE`
- `ig_markets console`
- `ig_markets help [COMMAND]`
- `ig_markets markets EPICS`
- `ig_markets orders [list]`
- `ig_markets orders create ...`
- `ig_markets orders update DEAL-ID ...`
- `ig_markets orders delete DEAL-ID`
- `ig_markets orders delete-all`
- `ig_markets performance --days N [...]`
- `ig_markets positions [list] [...]`
- `ig_markets positions create ...`
- `ig_markets positions update DEAL-ID ...`
- `ig_markets positions close DEAL-ID [...]`
- `ig_markets positions close-all [...]`
- `ig_markets prices --epic EPIC --resolution RESOLUTION ...`
- `ig_markets search QUERY [--type TYPE]`
- `ig_markets sentiment MARKET`
- `ig_markets sprints [list]`
- `ig_markets sprints create ...`
- `ig_markets transactions --days N [...]`
- `ig_markets watchlists [list]`
- `ig_markets watchlists create NAME [EPIC ...]`
- `ig_markets watchlists add-markets WATCHLIST-ID [EPIC ...]`
- `ig_markets watchlists remove-markets WATCHLIST-ID [EPIC ...]`
- `ig_markets watchlists delete WATCHLIST-ID`

#### Examples

```shell
# Print account details and balances
ig_markets account

# Print EUR/USD transactions from the last week, excluding interest transactions
ig_markets transactions --days 7 --instrument EUR/USD --no-interest

# Search for EURUSD currency markets
ig_markets search EURUSD --type currencies

# Print details for the EURUSD currency pair and the Dow Jones Industrial Average
ig_markets markets CS.D.EURUSD.CFD.IP IX.D.DOW.IFD.IP

# Print current positions in aggregate
ig_markets positions --aggregate

# Create a EURUSD long position of size 2
ig_markets positions create --direction buy --epic CS.D.EURUSD.CFD.IP --size 2 --currency-code USD

# Change the limit and stop levels for an existing position
ig_markets positions update DEAL-ID --limit-level 1.15 --stop-level 1.10

# Fully close a position
ig_markets positions close DEAL-ID

# Partially close a position (assuming its size is greater than 1)
ig_markets positions close DEAL-ID --size 1

# Create a EURUSD sprint market short position of size 100 that expires in 20 minutes
ig_markets sprints create --direction sell --epic FM.D.EURUSD24.EURUSD24.IP --expiry-period 20
                          --size 100

# Create a working order to buy 1 unit of EURUSD at the level 1.1
ig_markets orders create --direction buy --epic CS.D.EURUSD.CFD.IP --level 1.1 --size 1 --type limit
                         --currency-code USD

# Print daily prices for EURUSD from the last two weeks
ig_markets prices --epic CS.D.EURUSD.CFD.IP --resolution day --number 14

# Print account dealing performance from the last 90 days, broken down by the EPICs that were traded
ig_markets performance --days 90

# Log in and open a Ruby console which can be used to query the IG API, printing all REST requests
ig_markets console --verbose
```

## Usage — Library

#### Documentation

API documentation is available [here](http://www.rubydoc.info/github/rviney/ig_markets/master).

#### Examples

```ruby
require 'ig_markets'

ig = IGMarkets::DealingPlatform.new

# Session
ig.sign_in 'username', 'password', 'api_key', :demo
ig.sign_out

# Account
ig.account.all
ig.account.activities from: Date.today - 7
ig.account.activities from: Date.today - 14, to: Date.today - 7
ig.account.transactions from: Date.today - 7
ig.account.transactions from: Date.today - 14, to: Date.today - 7
ig.account.transactions from: Date.today - 14, to: Date.today - 7, type: :withdrawal

# Dealing
ig.deal_confirmation 'deal_reference'

# Positions
ig.positions.all
ig.positions.create currency_code: 'USD', direction: :buy, epic: 'CS.D.EURUSD.CFD.IP', size: 2
ig.positions['deal_id']
ig.positions['deal_id'].profit_loss
ig.positions['deal_id'].update limit_level: 1.2, stop_level: 1.1
ig.positions['deal_id'].reload
ig.positions['deal_id'].close

# Sprint market positions
ig.sprint_market_positions.all
ig.sprint_market_positions['deal_id']
ig.sprint_market_positions.create direction: :buy, epic: 'FM.D.EURUSD24.EURUSD24.IP',
                                  expiry_period: :twenty_minutes, size: 100

# Working orders
ig.working_orders.all
ig.working_orders.create currency_code: 'USD', direction: :buy, epic: 'CS.D.EURUSD.CFD.IP',
                         level: 0.99, size: 1, type: :limit
ig.working_orders['deal_id']
ig.working_orders['deal_id'].update level: 1.25, limit_distance: 50, stop_distance: 50
ig.working_orders['deal_id'].reload
ig.working_orders['deal_id'].delete

# Markets
ig.markets.hierarchy
ig.markets.search 'EURUSD'
ig.markets.find 'CS.D.EURUSD.CFD.IP', 'IX.D.DOW.IFD.IP'
ig.markets['CS.D.EURUSD.CFD.IP'].historical_prices resolution: :hour, number: 48
ig.markets['CS.D.EURUSD.CFD.IP'].historical_prices resolution: :second, from: Time.now - 120,
                                                   to: Time.now - 60

# Watchlists
ig.watchlists.all
ig.watchlists.create 'New Watchlist', 'CS.D.EURUSD.CFD.IP', 'UA.D.AAPL.CASH.IP'
ig.watchlists['watchlist_id']
ig.watchlists['watchlist_id'].markets
ig.watchlists['watchlist_id'].add_market 'CS.D.EURUSD.CFD.IP'
ig.watchlists['watchlist_id'].remove_market 'CS.D.EURUSD.CFD.IP'
ig.watchlists['watchlist_id'].delete

# Client sentiment
ig.client_sentiment['EURUSD']
ig.client_sentiment['EURUSD'].related_sentiments

# Miscellaneous
ig.applications
```

## Contributors

Gem created by Richard Viney. All contributions welcome.

[gem-link]: https://rubygems.org/gems/ig_markets
[gem-badge]: https://badge.fury.io/rb/ig_markets.svg
[travis-ci-link]: http://travis-ci.org/rviney/ig_markets
[travis-ci-badge]: https://travis-ci.org/rviney/ig_markets.svg?branch=master
[test-coverage-link]: https://codeclimate.com/github/rviney/ig_markets/coverage
[test-coverage-badge]: https://codeclimate.com/github/rviney/ig_markets/badges/coverage.svg
[code-climate-link]: https://codeclimate.com/github/rviney/ig_markets
[code-climate-badge]: https://codeclimate.com/github/rviney/ig_markets/badges/gpa.svg
[dependencies-link]: https://gemnasium.com/rviney/ig_markets
[dependencies-badge]: https://gemnasium.com/rviney/ig_markets.svg
[documentation-link]: https://inch-ci.org/github/rviney/ig_markets
[documentation-badge]: https://inch-ci.org/github/rviney/ig_markets.svg?branch=master
[license-link]: https://github.com/rviney/ig_markets/blob/master/LICENSE.md
[license-badge]: https://img.shields.io/badge/license-MIT-blue.svg
