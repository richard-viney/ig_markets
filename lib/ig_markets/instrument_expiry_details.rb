module IGMarkets
  class InstrumentExpiryDetails < Model
    attribute :last_dealing_date, type: :date_time, format: :unknown
    attribute :settlement_info
  end
end
