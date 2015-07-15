module IGMarkets
  class InstrumentExpiryDetails < Model
    attribute :last_dealing_date, type: DateTime
    attribute :settlement_info
  end
end
