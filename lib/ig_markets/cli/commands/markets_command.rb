module IGMarkets
  module CLI
    # Implements the `ig_markets markets` command.
    class Main < Thor
      desc 'markets EPICS', 'Prints the state of the markets with the specified EPICs'

      def markets(*epics)
        self.class.begin_session(options) do |dealing_platform|
          markets = dealing_platform.markets.find(*epics)

          table = MarketsTable.new markets

          puts table
        end
      end
    end
  end
end
