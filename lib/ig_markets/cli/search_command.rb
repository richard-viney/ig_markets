module IGMarkets
  module CLI
    # Implements the `ig_markets search` command.
    class Main < Thor
      desc 'search', 'Searches markets based on a query string'

      option :query, aliases: '-q', required: true, desc: 'The search query'

      def search
        self.class.begin_session(options) do |dealing_platform|
          dealing_platform.markets.search(options[:query]).each do |market|
            print_market_overview market
          end
        end
      end

      private

      def print_market_overview(market)
        puts <<-END
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
