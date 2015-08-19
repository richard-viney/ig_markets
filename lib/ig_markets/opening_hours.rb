module IGMarkets
  class OpeningHours < Model
    attribute :close_time
    attribute :open_time

    def self.from(value)
      super value.is_a?(Hash) ? value.fetch(:market_times) : value
    end
  end
end
