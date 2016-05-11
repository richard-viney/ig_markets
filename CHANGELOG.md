# IG Markets Changelog

### 0.11 — Unreleased

- Accept "`DFB`" (Daily Funded Bet) on instrument expiries, it is silently converted to `nil`

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
- Changed `size` attribute to always be of type `Float` on all models.
- Changed `limit_distance` and `stop_distance` attributes to always be of type `Fixnum` on all models.
- Added `IGMarkets::Format` module
- Added `#expired?` and `#seconds_till_expiry` to `IGMarkets::SprintMarketPosition`
- Fixed `IGMarkets::RequestFailedError#message`

### 0.1 — April 8, 2016

- Initial release
