module IGMarkets
  module CLI
    # Helper class that prints out an array of {IGMarkets::MarketOverview} instances in a table.
    class MarketOverviewsTable < Table
      private

      def default_title
        'Markets'
      end

      def headings
        %w(EPIC Instrument Type Bid Offer)
      end

      def right_aligned_columns
        [3, 4]
      end

      def row(market_overview)
        [
          market_overview.epic,
          market_overview.instrument_name,
          market_overview.instrument_type,
          market_overview.bid,
          market_overview.offer
        ]
      end
    end
  end
end
