module IGMarkets
  # Contains details on a currency used by an instrument. Returned by {Instrument#currencies}.
  class Currency < Model
    attribute :base_exchange_rate, Float
    attribute :code
    attribute :exchange_rate, Float
    attribute :is_default, Boolean
    attribute :symbol
  end
end
