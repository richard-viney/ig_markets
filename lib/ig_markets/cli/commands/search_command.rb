module IGMarkets
  module CLI
    # Implements the `ig_markets search` command.
    class Main < Thor
      desc 'search QUERY', 'Searches for markets using the specified query'

      option :type, type: :array, enum: Instrument.allowed_values(:type).map(&:to_s),
                    desc: 'Only match markets of the specified types'

      def search(query)
        self.class.begin_session(options) do |dealing_platform|
          market_overviews = gather_market_overviews dealing_platform, query

          table = MarketOverviewsTable.new market_overviews

          puts table
        end
      end

      private

      def gather_market_overviews(dealing_platform, query)
        market_overviews = dealing_platform.markets.search(query)

        if options[:type]
          market_overviews = market_overviews.select do |market_overview|
            options[:type].include? market_overview.instrument_type.to_s
          end
        end

        market_overviews
      end
    end
  end
end
