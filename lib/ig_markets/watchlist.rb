module IGMarkets
  class Watchlist < Model
    attribute :default_system_watchlist, Boolean
    attribute :deleteable, Boolean
    attribute :editable, Boolean
    attribute :id
    attribute :name
  end
end
