module IGMarkets
  class ClientSentiment
    include ActiveAttr::Model

    attribute :long_position_percentage, type: Float
    attribute :market_id
    attribute :short_position_percentage, type: Float

    def initialize(options = {})
      self.attributes = Helper.hash_with_snake_case_keys(options)
    end
  end
end
