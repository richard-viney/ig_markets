module IGMarkets
  module CLI
    # Implements the `ig_markets watchlists` command.
    class Main
      desc 'watchlists', 'Prints all watchlists and their markets'

      def watchlists
        self.class.begin_session(options) do |dealing_platform|
          dealing_platform.watchlists.all.each do |watchlist|
            Output.print_watchlist watchlist

            watchlist.markets.each do |market_overview|
              print '  - '
              Output.print_market_overview market_overview
            end

            print "\n"
          end
        end
      end
    end
  end
end
