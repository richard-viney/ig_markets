module IGMarkets
  module Streaming
    # Contains details on a consolidated chart data update received via the streaming API. Used by
    # {Streaming::Subscription#on_data}.
    class ConsolidatedChartDataUpdate < Model
      attribute :bid_close, Float
      attribute :bid_high, Float
      attribute :bid_low, Float
      attribute :bid_open, Float
      attribute :cons_end, Boolean
      attribute :cons_tick_count, Integer
      attribute :day_high, Float
      attribute :day_low, Float
      attribute :day_net_chg_mid, Float
      attribute :day_open_mid, Float
      attribute :day_perc_chg_mid, Float
      attribute :epic, String, regex: Regex::EPIC
      attribute :ltp_close, Float
      attribute :ltp_high, Float
      attribute :ltp_low, Float
      attribute :ltp_open, Float
      attribute :ltv, Float
      attribute :ofr_close, Float
      attribute :ofr_high, Float
      attribute :ofr_low, Float
      attribute :ofr_open, Float
      attribute :scale, Symbol, allowed_values: %i(one_second one_minute five_minutes one_hour)
      attribute :ttv, Float
      attribute :utm, Time, format: '%Q'
    end
  end
end
