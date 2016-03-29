module IGMarkets
  class ClientSentiment < Model
    attribute :long_position_percentage, Float
    attribute :market_id
    attribute :short_position_percentage, Float
  end
end
