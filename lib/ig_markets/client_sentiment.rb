module IGMarkets
  class ClientSentiment
    include ActiveAttr::Model

    attribute :long_position_percentage, type: Float
    attribute :market_id
    attribute :short_position_percentage, type: Float
  end
end
