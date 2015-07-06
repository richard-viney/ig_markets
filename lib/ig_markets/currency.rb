module IGMarkets
  class Currency
    include ActiveAttr::Model

    attribute :base_exchange_rate, type: Float
    attribute :code
    attribute :exchange_rate, type: Float
    attribute :is_default, type: Boolean
    attribute :symbol
  end
end
