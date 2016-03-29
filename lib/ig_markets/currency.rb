module IGMarkets
  class Currency < Model
    attribute :base_exchange_rate, Float
    attribute :code
    attribute :exchange_rate, Float
    attribute :is_default, Boolean
    attribute :symbol
  end
end
