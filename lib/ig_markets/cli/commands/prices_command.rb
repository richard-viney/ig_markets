module IGMarkets
  module CLI
    # Implements the `ig_markets prices` command.
    class Main
      desc 'prices', 'Prints historical prices for a market'

      option :epic, required: true, desc: 'The EPIC of the market to print historical prices for'
      option :resolution, enum: %w(minute minute-2 minute-3 minute-5 minute-10 minute-15 minute-30 hour hour-2 hour-3
                                   hour-4 day week month), required: true, desc: 'The price resolution'
      option :number, type: :numeric, desc: 'The number of historical prices to return, if this is specified then ' \
                                            '--start-date and --end-date are ignored, otherwise they are required'
      option :start_date, desc: 'The start of the period to return prices for, required unless --number is specified' \
                                ', format: yyyy-mm-ddThh:mm(+|-)zz:zz'
      option :end_date, desc: 'The end of the period to return prices for, required unless --number is specified' \
                              ', format: yyyy-mm-ddThh:mm(+|-)zz:zz'

      def prices
        self.class.begin_session(options) do |dealing_platform|
          result = historical_price_result dealing_platform
          allowance = result.metadata.allowance

          table = HistoricalPriceResultSnapshotsTable.new result.prices, title: "Prices for #{options[:epic]}"

          puts <<-END
#{table}

Allowance: #{allowance.total_allowance}
Remaining: #{allowance.remaining_allowance}
END
        end
      end

      private

      def resolution
        options[:resolution].to_s.tr('-', '_').to_sym
      end

      def historical_price_result(dealing_platform)
        market = dealing_platform.markets[options[:epic]]

        raise ArgumentError, 'invalid epic' unless market

        if options[:number]
          historical_price_result_from_number market
        elsif options[:start_date] && options[:end_date]
          historical_price_result_from_date_range market
        else
          raise ArgumentError, 'specify --number or both --start-date and --end-date'
        end
      end

      def historical_price_result_from_number(market)
        market.historical_prices resolution: resolution, max: options[:number]
      end

      def historical_price_result_from_date_range(market)
        filtered = self.class.filter_options options, [:start_date, :end_date]

        self.class.parse_date_time filtered, :start_date, Time, '%FT%R%z', 'yyyy-mm-ddThh:mm(+|-)zz:zz'
        self.class.parse_date_time filtered, :end_date, Time, '%FT%R%z', 'yyyy-mm-ddThh:mm(+|-)zz:zz'

        market.historical_prices resolution: resolution, from: filtered[:start_date], to: filtered[:end_date]
      end
    end
  end
end
