module IGMarkets
  class InstrumentExpiryDetails
    include ActiveAttr::Model

    attribute :last_dealing_date
    attribute :settlement_info
  end
end
