module IGMarkets
  class WorkingOrder < Model
    attribute :created_date, DateTime, format: '%Y/%m/%d %H:%M:%S:%L'
    attribute :created_date_utc, DateTime, format: '%Y-%m-%dT%H:%M:%S'
    attribute :currency_code, String, regex: Regex::CURRENCY
    attribute :deal_id
    attribute :direction, Symbol, allowed_values: [:buy, :sell]
    attribute :dma, Boolean
    attribute :epic, String, regex: Regex::EPIC
    attribute :good_till_date, DateTime, format: '%Y/%m/%d %H:%M'
    attribute :good_till_date_iso, DateTime, format: '%Y-%m-%dT%H:%M'
    attribute :guaranteed_stop, Boolean
    attribute :limit_distance, Float
    attribute :order_level, Float
    attribute :order_size, Float
    attribute :order_type, Symbol, allowed_values: [:limit, :stop]
    attribute :stop_distance, Float
    attribute :time_in_force, Symbol, allowed_values: [:good_till_cancelled, :good_till_date]

    attribute :market, MarketOverview
  end
end
