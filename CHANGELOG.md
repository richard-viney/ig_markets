# IG Markets Changelog

### Unreleased

- Support creating sprint market positions on the command-line with `ig_markets sprints create ...`
- `ig_markets confirmation`, `ig_markets search` and `ig_markets sentiment` now take their mandatory argument directly
  rather than as an option.
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
