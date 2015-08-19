module IGMarkets
  class OpeningHours < Model
    attribute :close_time
    attribute :open_time

    def self.from(value)
      if value.is_a?(Hash) && value.keys == [:market_times]
        super value[:market_times]
      else
        super
      end
    end
  end
end
