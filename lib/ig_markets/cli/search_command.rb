module IGMarkets
  module CLI
    # Implements the `ig_markets search` command.
    class Main < Thor
      desc 'search', 'Searches markets based on a query string'

      option :query, aliases: '-q', required: true, desc: 'The search query'

      def search
        begin_session do
          dealing_platform.markets.search(options[:query]).each do |market|
            print_market_overview market
          end
        end
      end

      private

      def print_market_overview(market)
        print <<-END
#{market.epic}: \
#{market.instrument_name}, \
type: #{market.instrument_type}, \
bid: #{market.bid} \
offer: #{market.offer}
END
      end
    end
  end
end
