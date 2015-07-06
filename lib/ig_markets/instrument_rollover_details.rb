module IGMarkets
  class InstrumentRolloverDetails
    include ActiveAttr::Model

    attribute :last_rollover_time
    attribute :rollover_info
  end
end
