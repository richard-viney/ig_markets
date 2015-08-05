module IGMarkets
  class ClientSentiment < Model
    attribute :long_position_percentage, typecaster: AttributeTypecasters.float
    attribute :market_id
    attribute :short_position_percentage, typecaster: AttributeTypecasters.float
  end
end
