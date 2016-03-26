module IGMarkets
  module Validate
    module_function

    def currency_code!(currency_code)
      raise ArgumentError, 'currency code is invalid' unless currency_code.to_s =~ /\A[A-Z]{3}\Z/
    end

    def direction!(direction)
      raise ArgumentError, 'direction is invalid' unless [:buy, :sell].include? direction
    end

    def epic!(*epics)
      epics.flatten.each do |epic|
        raise ArgumentError, 'epic is invalid' unless epic.to_s =~ /\A[A-Z,a-z,0-9,.,_]{6,30}\Z/
      end
    end

    HISTORICAL_PRICE_RESOLUTIONS = [
      :minute, :minute_2, :minute_3, :minute_5, :minute_10, :minute_15, :minute_30,
      :hour, :hour_2, :hour_3, :hour_4,
      :day, :week, :month
    ].freeze

    def historical_price_resolution!(resolution)
      raise ArgumentError, 'resolution is invalid' unless HISTORICAL_PRICE_RESOLUTIONS.include? resolution
    end

    ORDER_TYPES = [:limit, :market, :quote].freeze

    def order_type!(type)
      raise ArgumentError, 'order type is invalid' unless ORDER_TYPES.include? type
    end

    SPRINT_MARKET_EXPIRY_PERIODS = [
      :one_minute, :two_minutes, :five_minutes, :twenty_minutes, :sixty_minutes
    ].freeze

    def sprint_market_expiry_period!(period)
      raise ArgumentError, 'transaction type is invalid' unless SPRINT_MARKET_EXPIRY_PERIODS.include? period
    end

    POSITION_TIME_IN_FORCE_OPTIONS = [:execute_and_eliminate, :fill_or_kill].freeze

    def position_time_in_force!(option)
      raise ArgumentError, 'time in force is invalid' unless POSITION_TIME_IN_FORCE_OPTIONS.include? option
    end

    TRANSACTION_TYPES = [:all, :all_deal, :deposit, :withdrawal].freeze

    def transaction_type!(type)
      raise ArgumentError, 'transaction type is invalid' unless TRANSACTION_TYPES.include? type
    end

    WORKING_ORDER_TIME_IN_FORCE_OPTIONS = [:good_till_cancelled, :good_till_date].freeze

    def working_order_time_in_force!(option)
      raise ArgumentError, 'time in force is invalid' unless WORKING_ORDER_TIME_IN_FORCE_OPTIONS.include? option
    end

    WORKING_ORDER_TYPES = [:limit, :stop].freeze

    def working_order_type!(type)
      raise ArgumentError, 'working order type is invalid' unless WORKING_ORDER_TYPES.include? type
    end
  end
end
