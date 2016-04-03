module IGMarkets
  # Contains details on a trading position. See {DealingPlatform::PositionMethods#all} for usage details.
  class Position < Model
    attribute :contract_size, Float
    attribute :controlled_risk, Boolean
    attribute :created_date, DateTime, format: '%Y/%m/%d %H:%M:%S:%L'
    attribute :created_date_utc, DateTime, format: '%Y-%m-%dT%H:%M:%S'
    attribute :currency, String, regex: Regex::CURRENCY
    attribute :deal_id
    attribute :direction, Symbol, allowed_values: [:buy, :sell]
    attribute :level, Float
    attribute :limit_level, Float
    attribute :size, Float
    attribute :stop_level, Float
    attribute :trailing_step, Float
    attribute :trailing_stop_distance, Float

    attribute :market, MarketOverview
  end
end
