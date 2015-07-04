module IGMarkets
  class Market
    include ActiveAttr::Model

    attribute :bid
    attribute :delayTime
    attribute :epic
    attribute :expiry
    attribute :high
    attribute :instrument_name
    attribute :instrument_type
    attribute :lot_size
    attribute :low
    attribute :market_status
    attribute :net_change
    attribute :offer
    attribute :percentage_change
    attribute :scaling_factor
    attribute :streaming_prices_available
    attribute :update_time

    def initialize(options = {})
      self.attributes = Helper.hash_with_snake_case_keys(options)
    end
  end
end
