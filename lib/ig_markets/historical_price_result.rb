module IGMarkets
  # Contains details on a historical price query result. Returned by {Market#recent_prices} and
  # {Market#prices_in_date_range}.
  class HistoricalPriceResult < Model
    # Contains details on the remaining allowance for looking up historical prices. Used by {#allowance}.
    class DataAllowance < Model
      attribute :allowance_expiry, Fixnum
      attribute :remaining_allowance, Fixnum
      attribute :total_allowance, Fixnum
    end

    # Contains details on a single historical price. Used by {Snapshot}.
    class Price < Model
      attribute :ask, Float
      attribute :bid, Float
      attribute :last_traded, Float
    end

    # Contains details on a single historical price snapshot. Used by {#prices}.
    class Snapshot < Model
      attribute :close_price, Price
      attribute :high_price, Price
      attribute :last_traded_volume, Float
      attribute :low_price, Price
      attribute :open_price, Price
      attribute :snapshot_time, DateTime, format: '%Y/%m/%d %H:%M:%S'
    end

    attribute :allowance, DataAllowance
    attribute :instrument_type, Symbol, allowed_values: Instrument.allowed_values(:type)
    attribute :prices, Snapshot
  end
end
