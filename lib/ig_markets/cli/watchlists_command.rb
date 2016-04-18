module IGMarkets
  module CLI
    # Implements the `ig_markets watchlists` command.
    class Watchlists < Thor
      desc 'list', 'Prints all watchlists and their markets'

      def list
        Main.begin_session(options) do |dealing_platform|
          dealing_platform.watchlists.all.each do |watchlist|
            Output.print_watchlist watchlist

            watchlist.markets.each do |market_overview|
              print '  - '
              Output.print_market_overview market_overview
            end

            puts ''
          end
        end
      end

      default_task :list

      desc 'create NAME [EPIC EPIC ...]', 'Creates a new watchlist with the specified name and EPICs'

      def create(name, *epics)
        Main.begin_session(options) do |dealing_platform|
          new_watchlist = dealing_platform.watchlists.create(name, *epics)

          puts "New watchlist ID: #{new_watchlist.id}"
        end
      end

      desc 'add-markets WATCHLIST-ID EPIC [EPIC ...]', 'Adds the specified markets to a watchlist'

      def add_markets(watchlist_id, *epics)
        with_watchlist(watchlist_id) do |watchlist|
          epics.each do |epic|
            watchlist.add_market epic
          end
        end
      end

      desc 'remove-markets WATCHLIST-ID EPIC [EPIC ...]', 'Removes the specified markets from a watchlist'

      def remove_markets(watchlist_id, *epics)
        with_watchlist(watchlist_id) do |watchlist|
          epics.each do |epic|
            watchlist.remove_market epic
          end
        end
      end

      desc 'delete WATCHLIST-ID', 'Deletes the watchlist with the specified ID'

      def delete(watchlist_id)
        with_watchlist(watchlist_id, &:delete)
      end

      private

      def with_watchlist(watchlist_id)
        Main.begin_session(options) do |dealing_platform|
          watchlist = dealing_platform.watchlists[watchlist_id]

          raise 'no watchlist with the specified ID' unless watchlist

          yield watchlist
        end
      end
    end
  end
end
