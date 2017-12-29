# IG Markets Changelog

### 0.33 — Unreleased

- Added `DealingPlatform::ClientSentimentMethods#find` for retrieving multiple client sentiments in one request
- Added support for the `tradeable_no_edit` market state
- Use the paging support provided by the IG API when fetching large numbers of activities and transactions
- Switch to using the `ColorizedString` class instead of relying on extensions to the `String` class for colorizing

### 0.32 — May 27, 2017

- The `force_open` option now defaults to true for working orders, and is automatically set to true when creating a
  position that specifies a limit distance, limit level, stop distance, or stop level
- Added `--to` option to the `ig_markets activities`, `ig_markets transactions`, and `ig_markets performance`
  commands
- All timestamps provided to the `ig_markets activities`, `ig_markets transactions`, and `ig_markets performance`
  commands must now specify an explicit time zone
- Support the `unavailable` state on `IGMarkets::Streaming::MarketUpdate#market_state`
- Fix exception in the `ig_markets performance` command when no performance data is found
- Fixed `IGMarkets::AccountMethods#activities` and `IGMarkets::AccountMethods#transactions` sometimes returning
  duplicate entries

### 0.31 — March 26, 2017

- Added `IGMarkets::Streaming::PositionUpdate#currency` attribute
- Added proper detection of an invalid deal ID passed to `ig_markets orders update`
- Limited the update rate of `ig_markets stream` to 2Hz to avoid flickering caused by large numbers of simultaneous
  updates
- Fixed errors caused by a missing millisecond component on certain timestamps

### 0.30 — March 10, 2017

- Fixed `ig_markets self-test` command
- Support the `trade` transaction type

### 0.29 — March 8, 2017

- The `IGMarkets::AccountMethods#activities` and `IGMarkets::AccountMethods#transactions` now take `Time`
  values for `:from` and `:to` instead of `Date` values
- The `ig_markets activities`, `ig_markets performance` and `ig_markets transactions` commands now expect
  their optional `--from` option to be formatted as `yyyy-mm-ddThh:mm:ss`
- Fixed `IGMarkets::AccountMethods#activities` and `IGMarkets::AccountMethods#transactions` never returning
  if there were more than 500 activities or transactions in a single day during the specified period
- Added `IGMarkets::Position#limited_risk_premium` and `IGMarkets::WorkingOrder#limited_risk_premium`
- Support the `chart` transaction type

### 0.28 — February 24, 2017

- Added `IGMarkets::Instrument#limited_risk_premium`
- Added `IGMarkets::Transaction#open_date_utc`
- Added `#currency`, `#good_till_date`, `#order_type` and `#time_in_force` attributes to
  `IGMarkets::Streaming::WorkingOrderUpdate`
- Fixed `IGMarkets::AccountState` not updating its working orders when a level update is received
- Added `IGMarkets::Error::GetSessionTimeoutError` and `IGMarkets::Error::InvalidShareOrderInstrumentDataError`

### 0.27 — January 18, 2017

- Added `IGMarkets::Format.colored_currency`
- Fixed `ig_markets help` command not working when using a config file

### 0.26 — January 12, 2017

- Fully support Ruby 2.4
- Added `IGMarkets::Errors::MarketOrdersNotSupported` and `IGMarkets::Errors::TooManyMarketsError`
- Fixed incorrect exception messages when trying to set an invalid or disallowed value on an attribute
- Fixed the `ig_markets stream` command not finding the `curses` gem
- The `curses` gem is now installed automatically on non-Windows platforms

### 0.25 — December 7, 2016

- Increased required Ruby version to >= 2.2.2

### 0.24 — December 6, 2016

- Added `IGMarkets::DealConfirmation#channel` attribute which is used by the streaming API
- Updated to `codeclimate-test-reporter` 1.0

### 0.23 — October 19, 2016

- Use `Integer` instead of `Fixnum` in preparation for Ruby 2.4
- Fixed documentation warnings found by Inch CI

### 0.22 — October 3, 2016

- The `curses` gem is no longer a dependency because it can be difficult to install on Windows, it now has to be
  installed separately in order to use the `ig_markets stream` command that relies on curses functionality

### 0.21 — September 29, 2016

- Replaced `IGMarkets::Streaming::AccountState#data_to_process?` with
  `IGMarkets::Streaming::AccountState#data_queue_empty?`
- Fixed circular references in the `IGMarkets::DealingPlatform` subclasses
- All documented IG Markets API errors now have a matching `IGMarkets::IGMarketsError` subclass, and any unrecognized
  error codes returned by the API cause a warning to be written to `stderr`

### 0.20 — August 20, 2016

- Added `IGMarkets::DealingPlatform#streaming` which along with new classes in the `IGMarkets::Streaming` module
  provides a simple interface to the IG Markets streaming API
- Added `ig_markets stream` command that shows a live display of account balances, positions and working orders, the
  previous behavior of showing raw streaming output is still available using `ig_markets stream raw`
- Added new `IGMarkets::Position#deal_reference` attribute
- The `ig_markets self-test` command now runs self-tests on the streaming functionality as well
- Removed `IGMarkets::DealingPlatform#lightstreamer_session`

### 0.19 — August 5, 2016

- Added `ig_markets stream` command that displays live streaming data for accounts, markets and trading activity
- Added `IGMarkets::DealingPlatform#lightstreamer_session` that returns a `Lightstreamer::Session` instance that is
  ready to connect and start streaming data
- Improved parsing of expiry dates on instruments and dealing confirmations
- If the API returns an unexpected enum value then a one-time warning is now emitted and the value is treated as `nil`,
  this replaces the previous behavior of raising an exception and makes the library more future-proof
- When a traffic allowance is exceeded the time waited before retrying is now ten seconds instead of five
- HTTP response headers are now shown when in verbose mode

### 0.18 — August 2, 2016

- Added support for the recently added `#date` attribute on `IGMarkets::DealConfirmation`
- Fixed the second call to `IGMarkets::Session#sign_in` looping indefinitely if the previously logged in session was not
  explicitly signed out
- Fixed automatic re-sign-in when the client security token is invalid not working correctly
- Fixed exception when executing a `DELETE` request and verbose output is enabled

### 0.17 — July 27, 2016

- Switched to the `excon` HTTP library
- Replaced `IGMarkets::RequestFailedError` with a new `IGMarkets::IGMarketsError` class which is used as a base class
  for all errors raised by this gem
- Added a full set of error subclassses to give more accurate reporting of errors generated by the IG Markets API
- Documentation improvements

### 0.16 — July 20, 2016

- Switched to YAML for the `.ig_markets` config files and added support for storing multiple authentication profiles in
  the config files that can then be selected on the command-line using the new `--profile NAME` argument
- Added `IGMarkets::DealingPlatform#client_account_summary`
- Report the HTTP code when a request fails

### 0.15 — July 11, 2016

- Added `ig_markets self-test` command that can be run under a demo account in order to test the library against the
  live IG Markets API
- If the API key or account's traffic allowance is exceeded then `IGMarkets::Session` now automatically retries the
  request after a five second pause
- Added `IGMarkets::MarketHierarchyResult::HierarchyNode#markets` and
  `IGMarkets::MarketHierarchyResult::HierarchyNode#nodes` methods

### 0.14 — July 2, 2016

- Added `delete-all` subcommand to `ig_markets orders`
- Added a `#reload` method that reloads a model's attributes in-place to `IGMarkets::Account`,
  `IGMarkets::ClientSentiment`, `IGMarkets::Market`, `IGMarkets::Position` and `IGMarkets::WorkingOrder`
- Support mass assignment of attributes on models
- Fixed a compatibility issue with recent IG API changes

### 0.13 — June 22, 2016

- Added `ig_markets performance` command that summarizes an account's dealing performance over a specified period
- Added `ig_markets markets` command which prints the current state of all the passed EPICs
- Correctly handle instrument periods that are formatted as `DD-MMM-YY`
- The `:type` option to `IGMarkets::AccountMethods::transactions` is now validated
- The platform type previously referred to as `production` is now referred to as `live` to better match standard IG
  terminology, existing calls to `IGMarkets::DealingPlatform#sign_in` and `IGMarkets::Session#sign_in` will need to be
  updated if they explicitly specified `:production`

### 0.12 — June 21, 2016

- Unrecognized attributes returned by the IG Markets API now trigger a warning rather than causing an error, this makes
  the library able to handle new return values being added to existing APIs
- Upgraded to version 3 of the activities API, which significantly changes the structure of `IGMarkets::Activity`
- Accept "`DFB`" (daily funded bet) on instrument periods, it is silently converted to `nil`
- Correctly handle instrument periods that are formatted as `MMM-YY`
- Stops and limits can now be specified as levels rather than distances when creating and updating working orders
- Report profit/loss information when printing deal confirmations
- Renamed `--print-requests` option to `--verbose`
- The `--currency-code` option to `ig_markets positions create` and `ig_markets orders create` no longer defaults to
  `USD` and must be specified explicitly

### 0.11 — May 23, 2016

- `IGMarkets::DealingPlatform::AccountMethods#activities` and `IGMarkets::DealingPlatform::AccountMethods#transactions`
  now send as many requests as necessary in order to get around the fact that the IG Markets API caps the maximum number
  of results returned by a single request at 500
- `IGMarkets::DealingPlatform::AccountMethods#activities` and `IGMarkets::DealingPlatform::AccountMethods#transactions`
  no longer take a `:days` option, and their `:to` option defaults to today's date if it is omitted
- Accept "`DFB`" (daily funded bet) on instrument expiries, it is silently converted to `nil`
- Instrument high and low is now shown in the `ig_markets positions list` command

### 0.10 — May 10, 2016

- Added `--epic` option to the `ig_markets activities` command
- Added `--sort-by` option to the `ig_markets activities` and `ig_markets transactions` commands
- The `--instrument` option for `ig_markets transactions` is no longer case-sensitive
- Added `ig_markets positions close-all` to close all open positions at once
- Added `IGMarkets::DealingPlatform#disable_api_key`

### 0.9 — May 2, 2016

- `IGMarkets::DealingPlatform#sign_in` now returns an `IGMarkets::ClientAccountSummary` instance
- `IGMarkets::DealingPlatform::MarketMethods#find` can now handle being passed more than 50 EPICs at once
- Renamed `--start-date` option for `ig_markets activities` and `ig_markets transactions` commands to `--from`
- Deal confirmations reported by the command-line client are now retried after a five second pause if the initial
  request returns a 'deal not found' error

### 0.8 — April 30, 2016

- The `ig_markets prices` command now takes `--from` and `--to` arguments accurate to one second
- Fixed incomplete data being returned by `IGMarkets::DealingPlatform::AccountMethods#activities` and
  `IGMarkets::DealingPlatform::AccountMethods#transactions`
- Fixed errors calling `IGMarkets::DealingPlatform#instantiate_models` for models that have deprecated attributes

### 0.7 — April 30, 2016

- Added `ig_markets console` command which logs in then opens a live Ruby console
- Merged `IGMarkets::DealingPlatform::AccountMethods#activities_in_date_range` and
  `IGMarkets::DealingPlatform::AccountMethods#recent_activities` into
  `IGMarkets::DealingPlatform::AccountMethods#activities`
- Merged `IGMarkets::DealingPlatform::AccountMethods#transactions_in_date_range` and
  `IGMarkets::DealingPlatform::AccountMethods#recent_transactions` into
  `IGMarkets::DealingPlatform::AccountMethods#transactions`
- Merged `IGMarkets::Market#recent_prices` and `IGMarkets::Market#prices_in_date_range` into
  `IGMarkets::Market#historical_prices`
- Removed the `--account-time-zone` option and `IGMarkets::DealingPlatform#account_time_zone`
- Improved error reporting on assignment of invalid values to model attributes
- `IGMarkets::Model#inspect` now reports `Time` attributes in the local time zone
- Model attributes that are deprecated in the IG Markets API are now no longer included as part of the model classes

### 0.6 — April 27, 2016

- Added `ig_markets prices` command to print historical market prices
- Added `IGMarkets::DealingPlatform#account_time_zone` to handle the `Time` attributes that come back from the IG
  Markets API not in UTC and without a specified time zone
- Added `--account-time-zone` option to the command-line client, defaults to UTC
- Times reported by the command-line client are now in the local time zone instead of UTC
- Added `--type` option to `ig_markets search` to only show instruments of specific type(s)
- Use a default currency of `USD` for `ig_markets orders create` and `ig_markets positions create`
- Improved command-line client help output for several commands
- Added `IGMarkets::DealingPlatform::SprintMarketPositionMethods#[]`
- Fixed `IGMarkets::DealingPlatform::PositionMethods#[]` raising on an unknown deal ID
- Fixed `IGMarkets::Market#prices_in_date_range`

### 0.5 — April 23, 2016

- Output from the command-line client is now formatted using ASCII tables and contains a lot more detail
- Added `--aggregate` option to `ig_markets positions list` to aggregate together positions with the same EPIC
- Added `--instrument` option to `ig_markets transactions` to filter by instrument name
- Added `--no-interest` option to `ig_markets transactions` to exclude interest transactions
- Added `--print-requests` option to the command-line client to see all the interactions with the IG Markets API
- Support removal of limits and stops using `ig_markets positions update` and `ig_markets orders update`
- Removed `--related` option from `ig_markets sentiment`, related sentiments are now always reported and are also
  color-coded
- `IGMarkets::DealingPlatform::ClientSentimentMethods#[]` now raises an exception on unknown market IDs
- Added `IGMarkets::Position#close_level`
- Removed `IGMarkets::Position#formatted_size` and `IGMarkets::Transaction#formatted_transaction_type`

### 0.4 — April 17, 2016

- Added `create`, `update` and `delete` subcommands to `ig_markets orders`
- Added `create`, `update` and `close` subcommands to `ig_markets positions`
- Added `create` subcommand to `ig_markets sprints`
- Added `create`, `add-markets`, `remove-markets` and `delete` subcommands to `ig_markets watchlists`
- `ig_markets confirmation`, `ig_markets search` and `ig_markets sentiment` now take their mandatory argument directly
- Added `--start-date` option to the `ig_markets activities` and `ig_markets transactions` commands
- Removed the `:time_in_force` option from `IGMarkets::DealingPlatform::WorkingOrderMethods#create` and
  `IGMarkets::WorkingOrder#update`, just set `:good_till_date` if it is needed
- `IGMarkets::DealingPlatform::AccountMethods#recent_activities` and
  `IGMarkets::DealingPlatform::AccountMethods#recent_transactions` now take a number of days rather than a number of
  seconds
- Fixed errors working with a working order's `#good_till_date` attribute
- Automatically reauthenticate if the client security token has expired

### 0.3 — April 14, 2016

- Added `--version` and `-v` options to the command-line client

### 0.2 — April 14, 2016

- Added `ig_markets` command-line client
- `IGMarkets::Model` now has separate `Date` and `Time` attribute types, and a new `:time_zone` option is used for
  `Time` attributes that have a known time zone. Previous uses of `DateTime` should be replaced with either `Date` or
  `Time`.
- Changed `size` attribute to always be of type `Float` on all models
- Changed `limit_distance` and `stop_distance` attributes to always be of type `Fixnum` on all models
- Added `IGMarkets::Format` module
- Added `#expired?` and `#seconds_till_expiry` to `IGMarkets::SprintMarketPosition`
- Fixed `IGMarkets::RequestFailedError#message`

### 0.1 — April 8, 2016

- Initial release
