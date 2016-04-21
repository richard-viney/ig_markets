# IG Markets Changelog

### 0.5 - Unreleased

- The data displayed by the command-line client is now formatted as tables using the `terminal-table` gem
- Added `--print-requests` option to the command-line client to see all the interactions with the IG Markets API
- Added `--aggregate` option to `ig_markets positions list` to aggregate together positions with the same EPIC
- Added `--instrument` option to `ig_markets transactions` to filter by instrument name
- Support removal of limits and stops using `ig_markets positions update` and `ig_markets orders update`
- Added `IGMarkets::Position#close_level`
- Removed `IGMarkets::Position#formatted_size` and `IGMarkets#AccountTransaction#formatted_transaction_type`

### 0.4 - April 18, 2016

- Added `create`, `update` and `delete` subcommands to `ig_markets orders`
- Added `create`, `update` and `close` subcommands to `ig_markets positions`
- Added `create` subcommand to `ig_markets sprints`
- Added `create`, `add-markets`, `remove-markets` and `delete` subcommands to `ig_markets watchlists`
- `ig_markets confirmation`, `ig_markets search` and `ig_markets sentiment` now take their mandatory argument directly
- Added `--start-date` option to the `ig_markets activities` and `ig_markets transactions` commands
- Removed the `:time_in_force` option from `IGMarkets::WorkingOrderMethods#create` and `IGMarkets::WorkingOrder#update`,
  just set `:good_till_date` if it is needed
- `IGMarkets::AccountMethods#recent_activities` and `IGMarkets::AccountMethods#recent_transactions` now take a number of
  days rather than a number of seconds
- Fixed errors working with a working order's `#good_till_date` attribute
- Automatically reauthenticate if the client security token has expired

### 0.3 - April 14, 2016

- Added `--version` and `-v` options to the command-line client

### 0.2 - April 14, 2016

- Added `ig_markets` command-line client
- `IGMarkets::Model` now has separate `Date` and `Time` attribute types, and a new `:time_zone` option is used for
  `Time` attributes that have a known time zone. Previous uses of `DateTime` should be replaced with either `Date` or
  `Time`.
- Changed `size` attribute to always be of type `Float` on all models.
- Changed `limit_distance` and `stop_distance` attributes to always be of type `Fixnum` on all models.
- Added `IGMarkets::Format` module
- Added `#expired?` and `#seconds_till_expiry` to `IGMarkets::SprintMarketPosition`
- Fixed `IGMarkets::RequestFailedError#message`

### 0.1 - April 8, 2016

- Initial release
