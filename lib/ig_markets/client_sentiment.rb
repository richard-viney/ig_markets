module IGMarkets
  class ClientSentiment < Model
    attribute :long_position_percentage, type: :float
    attribute :market_id
    attribute :short_position_percentage, type: :float
  end
end
