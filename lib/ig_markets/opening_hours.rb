module IGMarkets
  class OpeningHours
    include ActiveAttr::Model

    attribute :close_time
    attribute :open_time
  end
end
