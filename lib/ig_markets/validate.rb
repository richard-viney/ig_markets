module IGMarkets
  # Contains methods for validating arguments passed to methods of IGMarkets::DealingPlatform.
  module Validate
    module_function

    # Validates the passed currency code, raising `ArgumentError` if it is invalid.
    def currency_code!(currency_code)
      raise ArgumentError, 'currency code is invalid' unless currency_code.to_s =~ /\A[A-Z]{3}\Z/
    end

    # Validates the passed direction, raising `ArgumentError` if it is invalid.
    def direction!(direction)
      raise ArgumentError, 'direction is invalid' unless [:buy, :sell].include? direction
    end

    # Validates the passed epic(s), raising `ArgumentError` if any are invalid.
    def epic!(*epics)
      epics.flatten.each do |epic|
        raise ArgumentError, 'epic is invalid' unless epic.to_s =~ /\A[A-Z,a-z,0-9,.,_]{6,30}\Z/
      end
    end

    # The valid historical price resolutions.
    HISTORICAL_PRICE_RESOLUTIONS = [
      :minute, :minute_2, :minute_3, :minute_5, :minute_10, :minute_15, :minute_30,
      :hour, :hour_2, :hour_3, :hour_4,
      :day, :week, :month
    ].freeze

    # Validates the passed historical price resolution, raising `ArgumentError` if it is invalid.
    def historical_price_resolution!(resolution)
      raise ArgumentError, 'resolution is invalid' unless HISTORICAL_PRICE_RESOLUTIONS.include? resolution
    end

    # The valid order types.
    ORDER_TYPES = [:limit, :market, :quote].freeze

    # Validates the passed order type, raising `ArgumentError` if it is invalid.
    def order_type!(type)
      raise ArgumentError, 'order type is invalid' unless ORDER_TYPES.include? type
    end

    # The valid sprint market expiry periods.
    SPRINT_MARKET_EXPIRY_PERIODS = [
      :one_minute, :two_minutes, :five_minutes, :twenty_minutes, :sixty_minutes
    ].freeze

    # Validates the passed sprint market expiry period, raising `ArgumentError` if any are invalid.
    def sprint_market_expiry_period!(period)
      raise ArgumentError, 'transaction type is invalid' unless SPRINT_MARKET_EXPIRY_PERIODS.include? period
    end

    # The valid position time in force options.
    POSITION_TIME_IN_FORCE_OPTIONS = [:execute_and_eliminate, :fill_or_kill].freeze

    # Validates the passed posiiton time in force, raising `ArgumentError` if it is invalid.
    def position_time_in_force!(option)
      raise ArgumentError, 'time in force is invalid' unless POSITION_TIME_IN_FORCE_OPTIONS.include? option
    end

    # The valid transaction types.
    TRANSACTION_TYPES = [:all, :all_deal, :deposit, :withdrawal].freeze

    # Validates the passed transaction type, raising `ArgumentError` if it is invalid.
    def transaction_type!(type)
      raise ArgumentError, 'transaction type is invalid' unless TRANSACTION_TYPES.include? type
    end

    # The valid working order time in force options.
    WORKING_ORDER_TIME_IN_FORCE_OPTIONS = [:good_till_cancelled, :good_till_date].freeze

    # Validates the passed working order time in force, raising `ArgumentError` if it is invalid.
    def working_order_time_in_force!(option)
      raise ArgumentError, 'time in force is invalid' unless WORKING_ORDER_TIME_IN_FORCE_OPTIONS.include? option
    end

    # The valid working order types.
    WORKING_ORDER_TYPES = [:limit, :stop].freeze

    # Validates the passed working order type, raising `ArgumentError` if it is invalid.
    def working_order_type!(type)
      raise ArgumentError, 'working order type is invalid' unless WORKING_ORDER_TYPES.include? type
    end
  end
end
