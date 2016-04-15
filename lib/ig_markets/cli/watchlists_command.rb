module IGMarkets
  module CLI
    # Implements the `ig_markets watchlists` command.
    class Main
      desc 'watchlists', 'Prints all watchlists and their markets'

      def watchlists
        self.class.begin_session(options) do |dealing_platform|
          dealing_platform.watchlists.all.each do |watchlist|
            print_watchlist watchlist

            watchlist.markets.each do |market|
              print '  - '
              print_market_overview market
            end
            print "\n"
          end
        end
      end

      private

      def print_watchlist(watchlist)
        puts <<-END
#{watchlist.id}: #{watchlist.name}, \
editable: #{watchlist.editable}, \
deleteable: #{watchlist.deleteable}, \
default: #{watchlist.default_system_watchlist}
END
      end
    end
  end
end
