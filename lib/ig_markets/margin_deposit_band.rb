module IGMarkets
  class MarginDepositBand
    include ActiveAttr::Model

    attribute :currency
    attribute :margin, type: Float
    attribute :max, type: Float
    attribute :min, type: Float
  end
end
