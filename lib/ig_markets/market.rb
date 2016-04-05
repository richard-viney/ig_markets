module IGMarkets
  # Contains details on a market, which is a combination of an {#instrument}, a set of {#dealing_rules}, and a
  # current {#snapshot} of the instrument's market. Returned by {DealingPlatform::MarketMethods#find} and
  # {DealingPlatform::MarketMethods#[]}.
  class Market < Model
    # Contains details on the dealing rules for a market. Returned by {#dealing_rules}.
    class DealingRules < Model
      # Contains specfics for a single dealing rule.
      class RuleDetails < Model
        attribute :unit, Symbol, allowed_values: [:percentage, :points]
        attribute :value, Float
      end

      attribute :market_order_preference, Symbol, allowed_values: [
        :available_default_off, :available_default_on, :not_available]
      attribute :max_stop_or_limit_distance, RuleDetails
      attribute :min_controlled_risk_stop_distance, RuleDetails
      attribute :min_deal_size, RuleDetails
      attribute :min_normal_stop_or_limit_distance, RuleDetails
      attribute :min_step_distance, RuleDetails
      attribute :trailing_stops_preference, Symbol, allowed_values: [:available, :not_available]
    end

    # Contains details on a snapshot of a market. Returned by {#snapshot}.
    class Snapshot < Model
      attribute :bid, Float
      attribute :binary_odds, Float
      attribute :controlled_risk_extra_spread, Float
      attribute :decimal_places_factor, Float
      attribute :delay_time, Float
      attribute :high, Float
      attribute :low, Float
      attribute :market_status, Symbol, allowed_values: [
        :closed, :edits_only, :offline, :on_auction, :on_auction_no_edits, :suspended, :tradeable]
      attribute :net_change, Float
      attribute :offer, Float
      attribute :percentage_change, Float
      attribute :scaling_factor, Float
      attribute :update_time
    end

    attribute :dealing_rules, DealingRules
    attribute :instrument, Instrument
    attribute :snapshot, Snapshot

    # Returns recent historical prices for this market at a specified resolution.
    #
    # @param [:minute, :minute_2, :minute_3, :minute_5, :minute_10, :minute_15, :minute_30, :hour, :hour_2, :hour_3,
    #         :hour_4, :day, :week, :month] resolution The resolution of the historical prices to return.
    # @param [Fixnum] num_points The number of historical prices to return.
    #
    # @return [HistoricalPriceResult]
    def recent_prices(resolution, num_points)
      validate_historical_price_resolution resolution

      url = "prices/#{instrument.epic}/#{resolution.to_s.upcase}/#{num_points.to_i}"

      HistoricalPriceResult.from @dealing_platform.session.get(url, API_V2)
    end

    # Returns historical prices for this market at a specified resolution over a specified time period.
    #
    # @param [:minute, :minute_2, :minute_3, :minute_5, :minute_10, :minute_15, :minute_30, :hour, :hour_2, :hour_3,
    #         :hour_4, :day, :week, :month] resolution The resolution of the historical prices to return.
    # @param [DateTime] start_date_time The start of the desired time period.
    # @param [DateTime] end_date_time The end of the desired time period.
    #
    # @return [HistoricalPriceResult]
    def prices_in_date_range(resolution, start_date_time, end_date_time)
      validate_historical_price_resolution resolution

      start_date_time = format_date_time start_date_time
      end_date_time = format_date_time end_date_time

      url = "prices/#{instrument.epic}/#{resolution.to_s.upcase}/#{start_date_time}/#{end_date_time}"

      HistoricalPriceResult.from @dealing_platform.session.get(url, API_V2)
    end

    private

    # Validates whether the passed argument is a valid historical price resolution.
    #
    # @param [Symbol] resolution The candidate historical price resolution to validate.
    def validate_historical_price_resolution(resolution)
      resolutions = [:minute, :minute_2, :minute_3, :minute_5, :minute_10, :minute_15, :minute_30, :hour, :hour_2,
                     :hour_3, :hour_4, :day, :week, :month]

      raise ArgumentError, 'resolution is invalid' unless resolutions.include? resolution
    end

    # Takes a `DateTime` and formats it for the historical prices API URLs.
    #
    # @param [DateTime] date_time The `DateTime` to format.
    def format_date_time(date_time)
      date_time.strftime '%Y-%m-%dT%H:%M:%S'
    end
  end
end
