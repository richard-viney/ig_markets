module IGMarkets
  class InstrumentExpiryDetails < Model
    attribute :last_dealing_date, type: :date_time, format: '%Y/%m/%d %H:%M:%S'
    attribute :settlement_info
  end
end
