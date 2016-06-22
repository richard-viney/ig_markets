module IGMarkets
  module CLI
    # Helper class that prints out an array of {IGMarkets::Market} instances in a table.
    class MarketsTable < MarketOverviewsTable
      private

      def row(market)
        [market.instrument.epic, market.instrument.type, market.instrument.name, market.snapshot.market_status,
         market.instrument.expiry, levels(market.snapshot)]
      end
    end
  end
end
