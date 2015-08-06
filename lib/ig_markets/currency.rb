module IGMarkets
  class Currency < Model
    attribute :base_exchange_rate, type: :float
    attribute :code
    attribute :exchange_rate, type: :float
    attribute :is_default, type: :boolean
    attribute :symbol
  end
end
