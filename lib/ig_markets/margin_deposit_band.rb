module IGMarkets
  class MarginDepositBand < Model
    attribute :currency
    attribute :margin, type: Float
    attribute :max, type: Float
    attribute :min, type: Float
  end
end
