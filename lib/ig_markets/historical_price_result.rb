module IGMarkets
  # Contains details on a historical price query result. Returned by {Market#historical_prices}.
  class HistoricalPriceResult < Model
    # Contains metadata associated with an historical price lookup. Used by {#metadata}.
    class Metadata < Model
      # Contains details on the remaining allowance for looking up historical prices. Used by {#allowance}.
      class Allowance < Model
        attribute :allowance_expiry, Fixnum
        attribute :remaining_allowance, Fixnum
        attribute :total_allowance, Fixnum
      end

      # Contains details on paging status for a historical price lookup. Used by {#page_data}.
      class PageData < Model
        attribute :page_number, Fixnum
        attribute :page_size, Fixnum
        attribute :total_pages, Fixnum
      end

      attribute :allowance, Allowance
      attribute :page_data, PageData
      attribute :size, Fixnum
    end

    # Contains details on a single historical price snapshot. Used by {#prices}.
    class Snapshot < Model
      # Contains details on a single historical price.
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
      attribute :snapshot_time_utc, Time, format: '%FT%T'

      deprecated_attribute :snapshot_time
    end

    attribute :instrument_type, Symbol, allowed_values: Instrument.allowed_values(:type)
    attribute :metadata, Metadata
    attribute :prices, Snapshot
  end
end
