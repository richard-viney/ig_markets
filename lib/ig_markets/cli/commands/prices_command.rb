module IGMarkets
  module CLI
    # Implements the `ig_markets prices` command.
    class Main
      desc 'prices', 'Prints historical prices for a market'

      option :epic, required: true, desc: 'The EPIC of the market to print historical prices for'
      option :resolution, enum: %w[second minute minute-2 minute-3 minute-5 minute-10 minute-15 minute-30 hour hour-2
                                   hour-3 hour-4 day week month], required: true, desc: 'The price resolution'
      option :number, type: :numeric, desc: 'The number of historical prices to return, if this is specified then ' \
                                            '--from and --to are ignored, otherwise they are required'
      option :from, desc: 'The start of the period to return prices for, required unless --number is specified, ' \
                          'format: yyyy-mm-ddThh:mm:ss(+|-)zz:zz'
      option :to, desc: 'The end of the period to return prices for, required unless --number is specified, ' \
                        'format: yyyy-mm-ddThh:mm:ss(+|-)zz:zz'

      def prices
        self.class.begin_session(options) do |dealing_platform|
          result = historical_price_result dealing_platform
          allowance = result.metadata.allowance

          table = Tables::HistoricalPriceResultSnapshotsTable.new result.prices, title: "Prices for #{options[:epic]}"

          puts <<~MSG
            #{table}

            Allowance: #{allowance.total_allowance}
            Remaining: #{allowance.remaining_allowance}
          MSG
        end
      end

      private

      def resolution
        options[:resolution].to_s.tr('-', '_').to_sym
      end

      def historical_price_result(dealing_platform)
        market = dealing_platform.markets[options[:epic]]

        raise ArgumentError, 'invalid EPIC' unless market

        if options[:number]
          historical_price_result_from_number market
        elsif options[:from] && options[:to]
          historical_price_result_from_date_range market
        else
          raise ArgumentError, 'specify --number or both --from and --to'
        end
      end

      def historical_price_result_from_number(market)
        market.historical_prices resolution: resolution, number: options[:number]
      end

      def historical_price_result_from_date_range(market)
        filtered_options = self.class.filter_options options, %i[from to]

        %i[from to].each do |attribute|
          self.class.parse_date_time filtered_options, attribute, Time, '%FT%T%z', 'yyyy-mm-ddThh:mm:ss(+|-)zz:zz'
        end

        market.historical_prices resolution: resolution, from: filtered_options[:from], to: filtered_options[:to]
      end
    end
  end
end
