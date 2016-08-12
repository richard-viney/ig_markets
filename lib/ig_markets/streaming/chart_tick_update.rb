module IGMarkets
  module Streaming
    # Contains details on a chart tick update received via the streaming API. Used by {Streaming::Subscription#on_data}.
    class ChartTickUpdate < Model
      attribute :bid, Float
      attribute :day_high, Float
      attribute :day_low, Float
      attribute :day_net_chg_mid, Float
      attribute :day_open_mid, Float
      attribute :day_perc_chg_mid, Float
      attribute :epic, String, regex: Regex::EPIC
      attribute :ltp, Float
      attribute :ltv, Float
      attribute :ofr, Float
      attribute :ttv, Float
      attribute :utm, Time, format: '%Q'
    end
  end
end
