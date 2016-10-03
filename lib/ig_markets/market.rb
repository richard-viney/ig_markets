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

      attribute :market_order_preference, Symbol, allowed_values: [:available_default_off, :available_default_on,
                                                                   :not_available]
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
      attribute :market_status, Symbol, allowed_values: [:closed, :edits_only, :offline, :on_auction,
                                                         :on_auction_no_edits, :suspended, :tradeable]
      attribute :net_change, Float
      attribute :offer, Float
      attribute :percentage_change, Float
      attribute :scaling_factor, Float
      attribute :update_time
    end

    attribute :dealing_rules, DealingRules
    attribute :instrument, Instrument
    attribute :snapshot, Snapshot

    # Reloads this market's attributes by re-querying the IG Markets API.
    def reload
      self.attributes = @dealing_platform.markets[instrument.epic].attributes
    end

    # Returns historical prices for this market at a given resolution, either the most recent prices by specifying the
    # `:number` option, or those from a date range by specifying the `:from` and `:to` options.
    #
    # @param [Hash] options The options hash.
    # @option options [:minute, :minute_2, :minute_3, :minute_5, :minute_10, :minute_15, :minute_30, :hour, :hour_2,
    #                  :hour_3, :hour_4, :day, :week, :month] :resolution The resolution of the prices to return.
    #                 Required.
    # @option options [Integer] :number The number of historical prices to return. If this is specified then the `:from`
    #                 and `:to` options must not be specified.
    # @option options [Time] :from The start of the period to return prices for.
    # @option options [Time] :to The end of the period to return prices for.
    #
    # @return [HistoricalPriceResult]
    def historical_prices(options)
      validate_historical_prices_options options

      options[:max] = options.delete(:number) if options.key? :number
      options[:from] = options[:from].utc.strftime '%FT%T' if options.key? :from
      options[:to] = options[:to].utc.strftime '%FT%T' if options.key? :to

      @dealing_platform.instantiate_models HistoricalPriceResult, historical_prices_request(options)
    end

    private

    # Validates the options passed to {#historical_prices}.
    def validate_historical_prices_options(options)
      resolutions = [:second, :minute, :minute_2, :minute_3, :minute_5, :minute_10, :minute_15, :minute_30, :hour,
                     :hour_2, :hour_3, :hour_4, :day, :week, :month]

      raise ArgumentError, 'resolution is invalid' unless resolutions.include? options[:resolution]

      return if options.keys == [:resolution, :from, :to] || options.keys == [:resolution, :number]

      raise ArgumentError, 'options must specify either :number or :from and :to'
    end

    # Returns the API response to a request for historical prices.
    def historical_prices_request(options)
      url = "prices/#{instrument.epic}?#{options.map { |key, value| "#{key}=#{value.to_s.upcase}" }.join '&'}"

      @dealing_platform.session.get url, API_V3
    end
  end
end
