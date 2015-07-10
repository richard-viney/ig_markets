module IGMarkets
  class ClientSentiment < Model
    attribute :long_position_percentage, type: Float
    attribute :market_id
    attribute :short_position_percentage, type: Float
  end
end
