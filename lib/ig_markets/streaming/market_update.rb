module IGMarkets
  module Streaming
    # Contains details on a market update received via the streaming API. Used by {Streaming::Subscription#on_data}.
    class MarketUpdate < Model
      attribute :bid, Float
      attribute :change, Float
      attribute :change_pct, Float
      attribute :epic, String, regex: Regex::EPIC
      attribute :high, Float
      attribute :low, Float
      attribute :market_delay, Boolean
      attribute :market_state, Symbol, allowed_values: [:closed, :offline, :tradeable, :edit, :auction,
                                                        :auction_no_edit, :suspended]
      attribute :mid_open, Float
      attribute :odds, Float
      attribute :offer, Float
      attribute :strike_price, Float
      attribute :update_time
    end
  end
end
