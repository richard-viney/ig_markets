module IGMarkets
  class Market < Model
    class DealingRules < Model
      attribute :market_order_preference, Symbol, allowed_values: [
        :available_default_off, :available_default_on, :not_available]
      attribute :max_stop_or_limit_distance, DealingRule
      attribute :min_controlled_risk_stop_distance, DealingRule
      attribute :min_deal_size, DealingRule
      attribute :min_normal_stop_or_limit_distance, DealingRule
      attribute :min_step_distance, DealingRule
      attribute :trailing_stops_preference, Symbol, allowed_values: [:available, :not_available]
    end

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
    # @return [Hash] A hash containing three keys: `:allowance` which is a {HistoricalPriceDataAllowance},
    #                `:instrument_type` which is a `Symbol`, and `:prices` which is an
    #                `Array<`{HistoricalPriceSnapshot}`>`.
    def recent_prices(resolution, num_points)
      validate_historical_price_resolution! resolution

      gather_prices "prices/#{instrument.epic}/#{resolution.to_s.upcase}/#{num_points.to_i}"
    end

    # Returns historical prices for this market at a specified resolution over a specified time period.
    #
    # @param [:minute, :minute_2, :minute_3, :minute_5, :minute_10, :minute_15, :minute_30, :hour, :hour_2, :hour_3,
    #         :hour_4, :day, :week, :month] resolution The resolution of the historical prices to return.
    # @param [DateTime] start_date_time
    # @param [DateTime] end_date_time
    #
    # @return [Hash] A hash containing three keys: `:allowance` which is a {HistoricalPriceDataAllowance},
    #                `:instrument_type` which is a `Symbol`, and `:prices` which is an
    #                `Array<`{HistoricalPriceSnapshot}`>`.
    def prices_in_date_range(resolution, start_date_time, end_date_time)
      validate_historical_price_resolution! resolution

      start_date_time = format_date_time start_date_time
      end_date_time = format_date_time end_date_time

      gather_prices "prices/#{instrument.epic}/#{resolution.to_s.upcase}/#{start_date_time}/#{end_date_time}"
    end

    private

    def validate_historical_price_resolution!(resolution)
      resolutions = [:minute, :minute_2, :minute_3, :minute_5, :minute_10, :minute_15, :minute_30, :hour, :hour_2,
                     :hour_3, :hour_4, :day, :week, :month]

      raise ArgumentError, 'resolution is invalid' unless resolutions.include? resolution
    end

    def gather_prices(url)
      result = @dealing_platform.session.get url, API_VERSION_2

      {
        allowance: HistoricalPriceDataAllowance.from(result.fetch(:allowance)),
        instrument_type: result.fetch(:instrument_type).downcase.to_sym,
        prices: HistoricalPriceSnapshot.from(result.fetch(:prices))
      }
    end

    def format_date_time(date_time)
      date_time.strftime '%Y-%m-%d %H:%M:%S'
    end
  end
end
