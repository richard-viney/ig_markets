module IGMarkets
  class MarginDepositBand < Model
    attribute :currency
    attribute :margin, type: :float
    attribute :max, type: :float
    attribute :min, type: :float
  end
end
