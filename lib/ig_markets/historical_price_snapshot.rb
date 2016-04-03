module IGMarkets
  # Contains details on a single historical price snapshot. Returned by {Market#recent_prices} and
  # {Market#prices_in_date_range}.
  class HistoricalPriceSnapshot < Model
    # Contains details on a single historical price. Used by {HistoricalPriceSnapshot}.
    class Price < Model
      attribute :ask, Float
      attribute :bid, Float
      attribute :last_traded, Float
    end

    attribute :close_price, Price
    attribute :high_price, Price
    attribute :last_traded_volume, Float
    attribute :low_price, Price
    attribute :open_price, Price
    attribute :snapshot_time, DateTime, format: '%Y/%m/%d %H:%M:%S'
  end
end
