module IGMarkets
  class Watchlist < Model
    attribute :id
    attribute :name
    attribute :editable
    attribute :deleteable
    attribute :default_system_watchlist
  end
end
