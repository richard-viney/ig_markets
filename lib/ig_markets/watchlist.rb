module IGMarkets
  class Watchlist
    include ActiveAttr::Model

    attribute :id
    attribute :name
    attribute :editable
    attribute :deleteable
    attribute :default_system_watchlist
  end
end
