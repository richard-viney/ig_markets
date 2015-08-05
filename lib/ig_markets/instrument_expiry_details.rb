module IGMarkets
  class InstrumentExpiryDetails < Model
    attribute :last_dealing_date, typecaster: AttributeTypecasters.date_time(nil)
    attribute :settlement_info
  end
end
