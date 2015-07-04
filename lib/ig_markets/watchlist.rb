module IGMarkets
  class Watchlist
    include ActiveAttr::Model

    attribute :id
    attribute :name
    attribute :editable
    attribute :deleteable
    attribute :default_system_watchlist

    def initialize(options = {})
      self.attributes = Helper.hash_with_snake_case_keys(options)
    end
  end
end
