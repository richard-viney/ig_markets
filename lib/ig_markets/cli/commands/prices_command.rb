module IGMarkets
  module CLI
    # Implements the `ig_markets prices` command.
    class Main
      desc 'prices', 'Prints historical prices for a market'

      option :epic, required: true, desc: 'The EPIC of the market to print historical prices for'
      option :resolution, enum: %w(minute minute_2 minute_3 minute_5 minute_10 minute_15 minute_30 hour hour_2 hour_3 \
                                   hour_4 day week month), desc: 'The resolution'
      option :number, type: :numeric, desc: 'The number of historical prices to return'
      option :start_date, desc: 'The start of the period to return prices for, format: yyyy-mm-ddThh:mm(+|-)zz:zz'
      option :end_date, desc: 'The end of the period to return prices for, format: yyyy-mm-ddThh:mm(+|-)zz:zz'

      def prices
        self.class.begin_session(options) do |dealing_platform|
          result = historical_price_result dealing_platform

          table = HistoricalPriceResultSnapshotsTable.new result.prices

          puts <<-END
#{table}

Allowance: #{result.allowance.total_allowance}
Remaining: #{result.allowance.remaining_allowance}
END
        end
      end

      private

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
        market.recent_prices options[:resolution], options[:number]
      end

      def historical_price_result_from_date_range(market)
        filtered = Main.filter_options options, [:resolution, :start_date, :end_date]

        Main.parse_date_time filtered, :start_date, Time, '%FT%R%z', 'yyyy-mm-ddThh:mm(+|-)zz:zz'
        Main.parse_date_time filtered, :end_date, Time, '%FT%R%z', 'yyyy-mm-ddThh:mm(+|-)zz:zz'

        market.prices_in_date_range filtered[:resolution], filtered[:start_date], filtered[:end_date]
      end
    end
  end
end
