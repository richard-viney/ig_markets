module IGMarkets
  # Contains methods for validating arguments passed to methods of IGMarkets::DealingPlatform.
  module Validate
    module_function

    # Regex used to validate an ISO currency code.
    CURRENCY_REGEX = /\A[A-Z]{3}\Z/

    # Regex used to validate an EPIC.
    EPIC_REGEX = /\A[A-Z,a-z,0-9,.,_]{6,30}\Z/

    # Validates the passed epic(s), raising `ArgumentError` if any are invalid.
    def epic!(*epics)
      epics.flatten.each do |epic|
        raise ArgumentError, 'epic is invalid' unless epic.to_s =~ EPIC_REGEX
      end
    end

    # Validates the passed historical price resolution, raising `ArgumentError` if it is invalid.
    def historical_price_resolution!(resolution)
      resolutions = [:minute, :minute_2, :minute_3, :minute_5, :minute_10, :minute_15, :minute_30, :hour, :hour_2,
                     :hour_3, :hour_4, :day, :week, :month]

      raise ArgumentError, 'resolution is invalid' unless resolutions.include? resolution
    end

    # Validates the passed order type, raising `ArgumentError` if it is invalid.
    def order_type!(type)
      raise ArgumentError, 'order type is invalid' unless [:limit, :market, :quote].include? type
    end

    # Validates the passed sprint market expiry period, raising `ArgumentError` if any are invalid.
    def sprint_market_expiry_period!(period)
      periods = [:one_minute, :two_minutes, :five_minutes, :twenty_minutes, :sixty_minutes]

      raise ArgumentError, 'transaction type is invalid' unless periods.include? period
    end

    # Validates the passed position time in force, raising `ArgumentError` if it is invalid.
    def position_time_in_force!(option)
      raise ArgumentError, 'time in force is invalid' unless [:execute_and_eliminate, :fill_or_kill].include? option
    end

    # Validates the passed transaction type, raising `ArgumentError` if it is invalid.
    def transaction_type!(type)
      raise ArgumentError, 'transaction type is invalid' unless [:all, :all_deal, :deposit, :withdrawal].include? type
    end
  end
end
